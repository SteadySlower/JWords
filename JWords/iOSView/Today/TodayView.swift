//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var showModal: Bool = false
    
    private let dependency: ServiceManager
    
    init(_ dependency: ServiceManager) {
        self.viewModel = ViewModel(dependency)
        self.dependency = dependency
    }
    
    var body: some View {
        ScrollView {
            todayBookList
                .padding(.bottom, 8)
            reviewBookList
        }
        .onAppear { viewModel.fetchSchedule() }
        .sheet(isPresented: $showModal, onDismiss: { viewModel.fetchSchedule() }) { TodaySelectionModal(dependency) }
        .toolbar { ToolbarItem { toolbarItems } }
    }
}

// MARK: SubViews

extension TodayView {
    
    private var todayBookList: some View {
        
        var onlyFailCell: some View {
            ZStack {
                NavigationLink {
                    LazyView(StudyView(words: viewModel.onlyFailWords, dependency: dependency))
                } label: {
                    HStack {
                        Text("틀린 \(viewModel.onlyFailWords.count) 단어만 모아보기")
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .border(.gray, width: 1)
            .frame(height: 50)
        }
        
        var body : some View {
            VStack {
                Text("오늘 학습할 단어")
                onlyFailCell
                VStack(spacing: 8) {
                    ForEach(viewModel.todayWordBooks, id: \.id) { todayBook in
                        HomeCell(wordBook: todayBook, dependency: dependency)
                    }
                }
            }
        }
        
        return body
    }
    
    private var reviewBookList: some View {
        VStack {
            Text("오늘 복습할 단어")
            VStack(spacing: 8) {
                ForEach(viewModel.reviewWordBooks, id: \.id) { reviewBook in
                    HomeCell(wordBook: reviewBook, dependency: dependency)
                }
            }
        }
    }
    
    private var toolbarItems: some View {
        HStack {
            Button("List") { showModal = true }
            Button("+") { viewModel.autoFetchTodayBooks() }
        }
    }
    
}

extension TodayView {
    final class ViewModel: ObservableObject {
        private var wordBooks: [WordBook] = []
        
        @Published private(set) var todayWordBooks: [WordBook] = []
        @Published private(set) var reviewWordBooks: [WordBook] = []
        @Published private(set) var onlyFailWords: [Word] = []
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        private let wordService: WordService
        
        init(_ dependency: ServiceManager) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
            self.wordService = dependency.wordService
        }
        
        func fetchSchedule() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                if let wordBooks = wordBooks {
                    self.wordBooks = wordBooks
                }
                self.todayService.getTodayBooks { todayBooks, error in
                    if error != nil {
                        return
                    }
                    guard let todayBooks = todayBooks else { return }
                    self.todayWordBooks = self.wordBooks.filter { todayBooks.studyIDs.contains($0.id) }
                    self.reviewWordBooks = self.wordBooks.filter {
                        todayBooks.reviewIDs.contains($0.id) && !todayBooks.reviewedIDs.contains($0.id)
                    }
                    self.fetchOnlyFailWords()
                }
            }
        }
        
        // TODO: handle error
        func autoFetchTodayBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                guard let wordBooks = wordBooks else { return }
                self.todayService.autoUpdateTodayBooks(wordBooks) { _ in
                    self.fetchSchedule()
                }
            }
        }
        
        // TODO: handle error + move logic to service
        func fetchOnlyFailWords() {
            var onlyFails = [Word]()
            let group = DispatchGroup()
            for todayWordBook in todayWordBooks {
                group.enter()
                wordService.getWords(wordBook: todayWordBook) { words, error in
                    if let error = error { print(error); }
                    if let words = words {
                        let onlyFail = words.filter { $0.studyState != .success }
                        onlyFails.append(contentsOf: onlyFail)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.onlyFailWords = onlyFails
            }
        }
    }
}

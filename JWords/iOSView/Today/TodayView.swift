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
    
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(dependency)
        self.dependency = dependency
    }
    
    var body: some View {
        ScrollView {
            OnlyFailCell(viewModel: viewModel, dependency: dependency)
            VStack(spacing: 8) {
                ForEach(viewModel.todayWordBooks, id: \.id) { todayBook in
                    HomeCell(wordBook: todayBook, dependency: dependency)
                }
            }
        }
        .onAppear { viewModel.fetchTodayBooks() }
        .sheet(isPresented: $showModal, onDismiss: { viewModel.fetchTodayBooks() }) { TodaySelectionModal(dependency) }
        .toolbar {
            ToolbarItem {
                Button("+") { showModal = true }
            }
        }
    }
}

extension TodayView {
    private struct OnlyFailCell: View {
        
        private let dependency: Dependency
        @ObservedObject private var viewModel: ViewModel
        
        init(viewModel: ViewModel, dependency: Dependency) {
            self.viewModel = viewModel
            self.dependency = dependency
        }
        
        var body: some View {
            ZStack {
                NavigationLink {
                    StudyView(words: viewModel.onlyFailWords, dependency: dependency)
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
        
    }
    
}

extension TodayView {
    final class ViewModel: ObservableObject {
        private var wordBooks: [WordBook] = []
        private var todayIDs: [String] = []
        
        @Published private(set) var todayWordBooks: [WordBook] = []
        @Published private(set) var onlyFailWords: [Word] = []
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        private let wordService: WordService
        
        init(_ dependency: Dependency) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
            self.wordService = dependency.wordService
        }
        
        func fetchTodayBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                if let wordBooks = wordBooks {
                    self.wordBooks = wordBooks.filter { !$0.closed }
                }
                self.todayService.getTodayBooks { todayIDs, error in
                    self.todayIDs = todayIDs!
                    self.todayWordBooks = self.wordBooks.filter { self.todayIDs.contains($0.id) }
                    self.fetchOnlyFailWords()
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

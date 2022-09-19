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
            OnlyFailCell(dependency: dependency)
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
        
        init(dependency: Dependency) {
            self.dependency = dependency
        }
        
        var body: some View {
            ZStack {
                NavigationLink {
                    StudyView(words: [], dependency: dependency)
                } label: {
                    HStack {
                        Text("틀린 단어 모아보기")
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
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        init(_ dependency: Dependency) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
        }
        
        func fetchTodayBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                if let wordBooks = wordBooks {
                    self.wordBooks = wordBooks
                }
                self.todayService.getTodayBooks { todayIDs, error in
                    self.todayIDs = todayIDs!
                    self.todayWordBooks = self.wordBooks.filter { self.todayIDs.contains($0.id) }
                }
            }
        }
    }
}

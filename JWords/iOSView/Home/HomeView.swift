//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var showModal = false
    
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(wordBookService: dependency.wordBookService)
        self.dependency = dependency
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(viewModel.wordBooks, id: \.id) { wordBook in
                    HomeCell(wordBook: wordBook, dependency: dependency)
                }
            }
        }
        .onAppear { viewModel.fetchWordBooks() }
        .sheet(isPresented: $showModal) { WordBookAddModal(viewModel: viewModel) }
        .toolbar {
            ToolbarItem {
                Button("+") { showModal = true }
            }
        }
    }
}

// MARK: SubViews
extension HomeView {
    private struct WordBookAddModal: View {
        @State var WordBookTitle: String = ""
        @Environment(\.dismiss) var dismiss
        private let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                TextField("단어장 이름", text: $WordBookTitle)
                HStack {
                    Button("추가", action: { viewModel.AddWordBook(WordBookTitle); dismiss()  })
                    Button("취소", role: .cancel, action: { dismiss() })
                }
            }
            .padding()
        }
    }
}

extension HomeView {
    final class ViewModel: ObservableObject {
        @Published private(set) var wordBooks: [WordBook] = []
        private let wordBookService: WordBookService
        
        init(wordBookService: WordBookService) {
            self.wordBookService = wordBookService
        }
        
        func fetchWordBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                if let error = error { print("디버그: \(error.localizedDescription)"); return }
                if let wordBooks = wordBooks {
                    self?.wordBooks = wordBooks.filter { $0.closed == false }
                }
            }
        }
        
        func AddWordBook(_ title: String) {
            wordBookService.saveBook(title: title) { [weak self] error in
                if let error = error {
                    print(error)
                    return
                }
                self?.fetchWordBooks()
            }
        }
    }
}

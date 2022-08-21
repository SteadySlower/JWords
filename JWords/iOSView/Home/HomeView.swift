//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject private var viewModel = ViewModel()
    @State private var showModal = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(viewModel.wordBooks) { wordBook in
                    HomeCell(wordBook: wordBook)
                }
            }
        }
        .navigationTitle("단어장 목록")
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
        @Environment(\.presentationMode) var mode
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
        
        private func dismiss() {
            mode.wrappedValue.dismiss()
        }
    }
}

extension HomeView {
    final class ViewModel: ObservableObject {
        @Published private(set) var wordBooks: [WordBook] = []
        private var isFetched: Bool = false
        
        func fetchWordBooks() {
            if isFetched { return }
            WordService.getWordBooks { [weak self] wordBooks, error in
                if let error = error { print("디버그: \(error.localizedDescription)"); return }
                if let wordBooks = wordBooks {
                    self?.wordBooks = wordBooks
                }
            }
        }
        
        func AddWordBook(_ title: String) {
            WordService.saveBook(title: title) { [weak self] error in
                if let error = error {
                    print(error)
                    return
                }
                self?.fetchWordBooks()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

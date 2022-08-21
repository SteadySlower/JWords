//
//  WordBookCloseView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI

struct WordBookCloseView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(wordBook: WordBook) {
        self.viewModel = ViewModel(toClose: wordBook)
//        viewModel.getWordBooks()
    }
    
    var body: some View {
        VStack {
            Text("틀린 단어들을 이동할 단어장을 골라주세요.")
            Picker("이동할 단어장 고르기", selection: $viewModel.selectedID) {
                if viewModel.wordBooks.isEmpty {
                    Text("로딩중")
                        .tag(nil as String?)
                }
                ForEach(viewModel.wordBooks, id: \.id) { wordbook in
                    Text(wordbook.title)
                        .tag(wordbook.id as String?)
                }
            }
            .pickerStyle(.wheel)
        }
        .onAppear { viewModel.getWordBooks() }
    }
}

extension WordBookCloseView {
    final class ViewModel: ObservableObject {
        private let toClose: WordBook
        @Published var wordBooks = [WordBook]()
        @Published var selectedID: String?
        
        init(toClose: WordBook) {
            self.toClose = toClose
        }
        
        func getWordBooks() {
            WordService.getWordBooks { wordBooks, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let wordBooks = wordBooks else {
                    print("Debug: No wordBook Found")
                    return
                }

                self.wordBooks = wordBooks
                print("디버그: \(self.wordBooks)")
            }
        }
    }
}

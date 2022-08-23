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
        // FIXME: 이 API 호출은 3번 실행됨. (Modal이 3번 init되기 때문)
        viewModel.getWordBooks()
    }
    
    var body: some View {
        VStack {
            Text("틀린 단어들을 이동할 단어장을 골라주세요.")
            Picker("이동할 단어장 고르기", selection: $viewModel.selectedID) {
                Text(viewModel.wordBooks.isEmpty ? "로딩중" : "이동 안함")
                    .tag(nil as String?)
                ForEach(viewModel.wordBooks) {
                    Text($0.title)
                        .tag($0.id as String?)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button("취소") {
                    dismiss()
                }
                Button("이동") {
                    
                }
            }
        }
    }
    
}

extension WordBookCloseView {
    final class ViewModel: ObservableObject {
        private let toClose: WordBook
        @Published var wordBooks = [WordBook]()
        var selectedID: String?
        
        init(toClose: WordBook) {
            self.toClose = toClose
        }
        
        func getWordBooks() {
            WordService.getWordBooks { [weak self] books, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let books = books else {
                    print("Debug: No wordbook Found")
                    return
                }
                
                self?.wordBooks = books
            }
        }
    }
}

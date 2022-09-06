//
//  MacAddBookView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

// TODO: pasteboard에 있는 이미지를 가져오는 코드
struct MacAddBookView: View {
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            TextField("단어장 이름", text: $viewModel.bookName)
                .padding()
            Button {
                viewModel.saveBook()
            } label: {
                Text("저장")
            }
            .disabled(viewModel.isSaveButtonUnable)
        }
    }
}

extension MacAddBookView {
    final class ViewModel: ObservableObject {
        @Published var bookName: String = ""
        private let wordBookService: WordBookService
        
        init(wordBookService: WordBookService = Dependency.wordBookService) {
            self.wordBookService = wordBookService
        }
        
        var isSaveButtonUnable: Bool {
            bookName.isEmpty
        }
        
        func saveBook() {
            wordBookService.saveBook(title: bookName) { [weak self] error in
                if let error = error { print("디버그 \(error.localizedDescription)"); return }
                self?.bookName = ""
            }
        }
    }
}

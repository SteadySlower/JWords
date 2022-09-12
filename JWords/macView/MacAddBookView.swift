//
//  MacAddBookView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

// TODO: pasteboard에 있는 이미지를 가져오는 코드
struct MacAddBookView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(wordBookService: dependency.wordBookService)
    }
    
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
        
        var isSaveButtonUnable: Bool {
            bookName.isEmpty
        }
        
        init(wordBookService: WordBookService) {
            self.wordBookService = wordBookService
        }
        
        func saveBook() {
            wordBookService.saveBook(title: bookName) { [weak self] error in
                if let error = error {
                    print("디버그 \(error.localizedDescription)");
                    return
                }
                self?.bookName = ""
            }
        }
    }
}

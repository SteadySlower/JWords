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
        
        var isSaveButtonUnable: Bool {
            !bookName.isEmpty
        }
        
        func saveBook() {
            WordService.saveBook(title: bookName) { [weak self] error in
                if let error = error { print(error.localizedDescription); return }
                self?.bookName = ""
            }
        }
    }
}

struct MacAddBookView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddBookView()
    }
}

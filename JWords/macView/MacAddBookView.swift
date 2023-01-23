//
//  MacAddBookView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI


struct MacAddBookView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(wordBookService: dependency.wordBookService)
    }
    
    var body: some View {
        VStack {
            TextField("단어장 이름", text: $viewModel.bookName)
                .padding()
            Picker("", selection: $viewModel.preferredFrontType) {
                ForEach(FrontType.allCases, id: \.self) {
                    Text($0.preferredTypeText)
                }
            }
            .pickerStyle(.segmented)
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
        @Published var preferredFrontType: FrontType = .kanji
        private let wordBookService: WordBookService
        
        var isSaveButtonUnable: Bool {
            bookName.isEmpty
        }
        
        init(wordBookService: WordBookService) {
            self.wordBookService = wordBookService
        }
        
        func saveBook() {
            wordBookService.saveBook(title: bookName, preferredFrontType: preferredFrontType) { [weak self] error in
                if let error = error {
                    print("디버그 \(error.localizedDescription)");
                    return
                }
                self?.bookName = ""
            }
        }
    }
}

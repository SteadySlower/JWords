//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct StudyView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(wordBook: WordBook) {
        self.viewModel = ViewModel(wordBook: wordBook)
    }
    
    var body: some View {
        ScrollView {
            VStack {}
            .frame(height: Constants.Size.deviceHeight / 5)
            VStack(spacing: 32) {
                ForEach(viewModel.words) { word in
                    WordCell(word: word)
                }
            }
        }
        .navigationTitle(viewModel.wordBook.title)
        .onAppear{ viewModel.updateWords() }
    }
}

extension StudyView {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        @Published var words: [Word] = []
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
        
        func updateWords() {
            WordService.getWords(wordBookID: wordBook.id!) { [weak self] words, error in
                if let error = error {
                    print("디버그: \(error)")
                }
                guard let words = words else { return }
                self?.words = words
            }
        }
    }
}


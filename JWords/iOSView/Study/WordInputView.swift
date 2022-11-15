//
//  WordInputView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/06.
//

import SwiftUI

struct WordInputView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(_ word: Word? = nil, dependency: Dependency) {
        self.viewModel = ViewModel(word: word, dependency: dependency)
    }
    
    var body: some View {
        VStack {
            Text(viewModel.word == nil ? "단어 추가하기" : "단어 수정하기")
                .padding()
            TextEditor(text: $viewModel.meaningText)
                .border(.black)
                .padding()
            TextEditor(text: $viewModel.kanjiText)
                .border(.black)
                .padding()
            TextEditor(text: $viewModel.ganaText)
                .border(.black)
                .padding()
            Button("저장") {
                viewModel.saveButtonTapped { dismiss() }
            }
        }
        
    }
}

extension WordInputView {
    final class ViewModel: ObservableObject {
        let word: Word?
        
        @Published var meaningText: String
        @Published var kanjiText: String
        @Published var ganaText: String
        
        private let wordService: WordService
        
        init(word: Word?, dependency: Dependency) {
            self.word = word
            self.meaningText = word?.meaningText ?? ""
            self.kanjiText = word?.kanjiText ?? ""
            self.ganaText = word?.ganaText ?? ""
            self.wordService = dependency.wordService
        }
        
        func saveButtonTapped(_ completionHandler: @escaping () -> Void) {
            if let word = word {
                editWord(word, completionHandler)
            } else {
                addWord()
            }
        }
            
        private func addWord() {
            
        }
        
        private func editWord(_ word: Word, _ completionHandler: @escaping () -> Void) {
            let wordInput = WordInputImpl(wordBookID: word.wordBookID, meaningText: meaningText, meaningImage: nil, ganaText: ganaText, ganaImage: nil, kanjiText: kanjiText, kanjiImage: nil)
            wordService.updateWord(word, wordInput) { error in
                //TODO: handle error (in completionHandler as well)
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                completionHandler()
            }
        }
    }
}

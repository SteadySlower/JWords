//
//  WordInputView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/06.
//

import SwiftUI

struct WordInputView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(_ word: Word? = nil) {
        self.viewModel = ViewModel(word: word)
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
                viewModel.saveButtonTapped()
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
        
        init(word: Word?) {
            self.word = word
            self.meaningText = word?.meaningText ?? ""
            self.kanjiText = word?.kanjiText ?? ""
            self.ganaText = word?.ganaText ?? ""
        }
        
        func saveButtonTapped() {
            
        }
            
        private func addWord() {
            
        }
        
        private func updateWord() {
            
        }
    }
}

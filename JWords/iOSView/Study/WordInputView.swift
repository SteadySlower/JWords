//
//  WordInputView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/06.
//

import SwiftUI

struct WordInputView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init() {
        self.viewModel = ViewModel()
    }
    
    init(_ word: Word) {
        self.viewModel = ViewModel(word: word)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.meaningText)
            TextEditor(text: $viewModel.kanjiText)
            TextEditor(text: $viewModel.ganaText)
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
        
        init(word: Word) {
            self.word = word
            self.meaningText = word.meaningText
            self.kanjiText = word.kanjiText
            self.ganaText = word.ganaText
        }
        
        init() {
            self.word = nil
            self.meaningText = ""
            self.kanjiText = ""
            self.ganaText = ""
        }
        
        func saveButtonTapped() {
            
        }
            
        private func addWord() {
            
        }
        
        private func updateWord() {
            
        }
    }
}

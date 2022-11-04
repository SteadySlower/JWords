//
//  WordInputView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/06.
//

import SwiftUI

struct WordInputView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(word: Binding<Word>) {
        self.viewModel = ViewModel(word: word)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.word.meaningText)
            TextEditor(text: $viewModel.word.ganaText)
            Button("수정") {
                print("EditButton Pressed")
            }
        }
        
    }
}

extension WordInputView {
    final class ViewModel: ObservableObject {
        @Binding var word: Word
        
        init(word: Binding<Word>) {
            self._word = word
        }
        
        func updateWord() {
            
        }
    }
}

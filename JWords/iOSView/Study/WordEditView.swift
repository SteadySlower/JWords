//
//  WordEditView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/06.
//

import SwiftUI

struct WordEditView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(word: Binding<Word>) {
        self.viewModel = ViewModel(word: word)
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $viewModel.word.frontText)
            TextEditor(text: $viewModel.word.backText)
            Button("수정") {
                print("EditButton Pressed")
            }
        }
        
    }
}

extension WordEditView {
    final class ViewModel: ObservableObject {
        @Binding var word: Word
        
        init(word: Binding<Word>) {
            self._word = word
        }
        
        func updateWord() {
            
        }
    }
}

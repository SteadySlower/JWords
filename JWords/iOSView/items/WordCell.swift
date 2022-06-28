//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct WordCell: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var isFront = true
    @State private var studyState: StudyState = .undefined
    @State private var dragWidth: CGFloat = 0
    
    init(word: Word) {
        self.viewModel = ViewModel(word: word)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CellColor(state: $studyState)
                if isFront {
                    VStack {
                        if !viewModel.word.frontText.isEmpty { Text(viewModel.word.frontText) }
                        if !viewModel.word.frontImageURL.isEmpty { Text(viewModel.word.frontImageURL) }
                    }
                } else {
                    VStack {
                        if !viewModel.word.backText.isEmpty { Text(viewModel.word.backText) }
                        if !viewModel.word.backImageURL.isEmpty { Text(viewModel.word.backImageURL) }
                    }
                }
            }
            .position(x: proxy.frame(in: .local).midX + dragWidth, y: proxy.frame(in: .local).midY)
            .onTapGesture { isFront.toggle() }
            // TODO: Drag 제스처에 대해서 (List의 swipe action에 대해서도!)
            .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global)
                .onChanged({ value in
                    self.dragWidth =  value.translation.width
                })
                .onEnded({ value in
                    self.dragWidth = 0
                    if value.translation.width < 0 {
                        self.studyState = .success
                    } else {
                        self.studyState = .fail
                    }
                }))
        }
    }
    
    private struct CellColor: View {
        @Binding var state: StudyState
        
        var body: some View {
            switch state {
            case .undefined:
                Color.white
            case .success:
                Color(red: 207/256, green: 240/256, blue: 204/256)
            case .fail:
                Color(red: 253/256, green: 253/256, blue: 150/256)
            }
        }
    }
}

extension WordCell {
    final class ViewModel: ObservableObject {
        var word: Word
        
        init(word: Word) {
            self.word = word
        }
    }
}

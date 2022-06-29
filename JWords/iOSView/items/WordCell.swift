//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Kingfisher

struct WordCell: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var isFront = true
    @State private var dragWidth: CGFloat = 0
    
    init(word: Word) {
        self.viewModel = ViewModel(word: word)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CellColor(state: $viewModel.word.studyState)
                if isFront {
                    VStack {
                        if !viewModel.word.frontText.isEmpty {
                            Text(viewModel.word.frontText)
                        }
                        if !viewModel.word.frontImageURL.isEmpty {
                            KFImage(viewModel.frontImageURL)
                                .resizable()
                                .frame(width: proxy.frame(in: .local).width * 0.9)
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                } else {
                    VStack {
                        if !viewModel.word.backText.isEmpty {
                            Text(viewModel.word.backText)
                        }
                        if !viewModel.word.backImageURL.isEmpty {
                            KFImage(viewModel.backImageURL)
                                .resizable()
                                .frame(width: proxy.frame(in: .local).width * 0.9)
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                }
            }
            .position(x: proxy.frame(in: .local).midX + dragWidth, y: proxy.frame(in: .local).midY)
            // TODO: 더블탭이랑 탭이랑 같이 쓸 때 더블탭을 위에 놓아야 함(https://stackoverflow.com/questions/58539015/swiftui-respond-to-tap-and-double-tap-with-different-actions)
            .simultaneousGesture(TapGesture(count: 2).onEnded {
                viewModel.word.studyState = .undefined
            })
            .gesture(TapGesture().onEnded {
                isFront.toggle()
            })
            // TODO: Drag 제스처에 대해서 (List의 swipe action에 대해서도!)
            .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .global)
                .onChanged({ value in
                    self.dragWidth =  value.translation.width
                })
                .onEnded({ value in
                    self.dragWidth = 0
                    if value.translation.width < 0 {
                        self.viewModel.word.studyState = .success
                    } else {
                        self.viewModel.word.studyState = .fail
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
        
        var frontImageURL: URL? {
            URL(string: word.frontImageURL)
        }
        
        var backImageURL: URL? {
            URL(string: word.backImageURL)
        }
    }
}

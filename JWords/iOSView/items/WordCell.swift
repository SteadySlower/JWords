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
    private var hasImage: Bool {
        if isFront {
            return viewModel.word.frontImageURL.isEmpty ? false : true
        } else {
            return viewModel.word.backImageURL.isEmpty ? false : true
        }
    }
    
    init(wordBook: WordBook, word: Binding<Word>) {
        self.viewModel = ViewModel(wordBook: wordBook, word: word)
        viewModel.prefetchImage()
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack {
                    let imageHeight = proxy.frame(in: .local).height * 0.8
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: imageHeight, height: imageHeight)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: imageHeight, height: imageHeight)
                        .foregroundColor(.red)
                    
                }
                ZStack {
                    CellColor(state: $viewModel.word.studyState)
                    if isFront {
                        VStack {
                            if !viewModel.word.frontText.isEmpty {
                                Text(viewModel.word.frontText)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 48))
                                    .lineLimit(3)
                            }
                            if !viewModel.word.frontImageURL.isEmpty {
                                KFImage(viewModel.frontImageURL)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    } else {
                        VStack {
                            if !viewModel.word.backText.isEmpty {
                                Text(viewModel.word.backText)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 48))
                                    .lineLimit(3)
                            }
                            if !viewModel.word.backImageURL.isEmpty {
                                KFImage(viewModel.backImageURL)
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
                .position(x: proxy.frame(in: .local).midX + dragWidth, y: proxy.frame(in: .local).midY)
                // TODO: 더블탭이랑 탭이랑 같이 쓸 때 더블탭을 위에 놓아야 함(https://stackoverflow.com/questions/58539015/swiftui-respond-to-tap-and-double-tap-with-different-actions)
                .simultaneousGesture(TapGesture(count: 2).onEnded {
                    viewModel.updateToUndefined()
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
                        if value.translation.width > 0 {
                            viewModel.updateToSuccess()
                        } else {
                            viewModel.updateToFail()
                        }
                    }))
            }
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
        let wordBook: WordBook
        @Binding var word: Word
        
        init(wordBook: WordBook, word: Binding<Word>) {
            self.wordBook = wordBook
            self._word = word
        }
        
        var frontImageURL: URL? {
            URL(string: word.frontImageURL)
        }
        
        var backImageURL: URL? {
            URL(string: word.backImageURL)
        }
        
        func updateToSuccess() {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = word.id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: .success) { error in
                // FIXME: handle error
                if let error = error { print(error); return }
                self.word.studyState = .success
            }
        }
        
        func updateToFail() {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = word.id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: .fail) { error in
                // FIXME: handle error
                if let error = error { print(error); return }
                self.word.studyState = .fail
            }
        }
        
        func updateToUndefined() {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = word.id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: .undefined) { error in
                // FIXME: handle error
                if let error = error { print(error); return }
                self.word.studyState = .undefined
            }
        }
        
        func prefetchImage() {
            guard word.hasImage == true else { return }
            let urls = [word.frontImageURL, word.backImageURL].compactMap { URL(string: $0) }
            let prefetcher = ImagePrefetcher(urls: urls) {
                skippedResources, failedResources, completedResources in
                print("prefetched image: \(completedResources)")
            }
            prefetcher.start()
        }
    }
}

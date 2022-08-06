//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Kingfisher
import Combine

protocol WordCellDelegate: AnyObject {
    var toFrontPublisher: PassthroughSubject<Void, Never> { get }
    
    func didUpdateState(id: String?, state: StudyState)
    func showEditModal(id: String?)
}

struct WordCell: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var isFront = true
    @State private var dragWidth: CGFloat = 0
    private let toFrontPublisher: PassthroughSubject<Void, Never>
    
    private var hasImage: Bool {
        if isFront {
            return viewModel.word.frontImageURL.isEmpty ? false : true
        } else {
            return viewModel.word.backImageURL.isEmpty ? false : true
        }
    }
    
    init(wordBook: WordBook, word: Binding<Word>, delegate: WordCellDelegate) {
        self.viewModel = ViewModel(wordBook: wordBook, word: word, delegate: delegate)
        self.toFrontPublisher = delegate.toFrontPublisher
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
                .onReceive(toFrontPublisher) {
                    isFront = true
                }
                .position(x: proxy.frame(in: .local).midX + dragWidth, y: proxy.frame(in: .local).midY)
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
                    })
                )
                // TODO: 더블탭이랑 탭이랑 같이 쓸 때 더블탭을 위에 놓아야 함(https://stackoverflow.com/questions/58539015/swiftui-respond-to-tap-and-double-tap-with-different-actions)
                .gesture(TapGesture(count: 2).onEnded {
                    viewModel.updateToUndefined()
                })
                .gesture(TapGesture().onEnded {
                    isFront.toggle()
                })
                .onLongPressGesture {
                    // FIXME: this is about view!!! not about logic
                    viewModel.showEditModal()
                }
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
        private let delegate: WordCellDelegate
        
        init(wordBook: WordBook, word: Binding<Word>, delegate: WordCellDelegate) {
            self.wordBook = wordBook
            self._word = word
            self.delegate = delegate
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
                self.delegate.didUpdateState(id: wordID, state: .success)
            }
        }
        
        func updateToFail() {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = word.id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: .fail) { error in
                // FIXME: handle error
                if let error = error { print(error); return }
                self.delegate.didUpdateState(id: wordID, state: .fail)
            }
        }
        
        func updateToUndefined() {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = word.id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: .undefined) { error in
                // FIXME: handle error
                if let error = error { print(error); return }
                self.delegate.didUpdateState(id: wordID, state: .undefined)
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
        
        func showEditModal() {
            delegate.showEditModal(id: word.id)
        }
    }
}

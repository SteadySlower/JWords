//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Kingfisher
import Combine

struct WordCell: View {
    // MARK: Properties
    @ObservedObject private var viewModel: ViewModel
    @GestureState private var dragAmount = CGSize.zero
    @State private var isFront = true
    private let isLocked: Bool
    
    // MARK: Initializer
    init(word: Word, frontType: FrontType, eventPublisher: PassthroughSubject<Event, Never>, isLocked: Bool) {
        self.viewModel = ViewModel(word: word, frontType: frontType, eventPublisher: eventPublisher)
        self.isLocked = isLocked
        viewModel.prefetchImage()
    }
    
    // MARK: Body
    var body: some View {
        ZStack {
            contentView
                .onReceive(viewModel.eventPublisher) { handleEvent($0) }
                .gesture(dragGesture)
                .gesture(doubleTapGesture)
                .gesture(tapGesture)
        }
    }
}

// MARK: SubViews

extension WordCell {
    
    private var contentView: some View {
        GeometryReader { proxy in
            ZStack {
                WordCellBackground(imageHeight: proxy.frame(in: .local).height * 0.8)
                ZStack {
                    CellColor(state: viewModel.word.studyState)
                    if isFront {
                        WordCellFace(text: viewModel.frontText, imageURLs: viewModel.frontImageURLs)
                    } else {
                        WordCellFace(text: viewModel.backText, imageURLs: viewModel.backImageURLs)
                    }
                }
                .offset(dragAmount)
            }
        }
    }
    
    private struct CellColor: View {
        private let state: StudyState
        
        init(state: StudyState) {
            self.state = state
        }
        
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
    
    private struct WordCellBackground: View {
        let imageHeight: CGFloat
        
        var body: some View {
            HStack {
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
        }
    }
    
    private struct WordCellFace: View {
        let text: String
        let imageURLs: [URL]
        
        var body: some View {
            VStack {
                Text(text)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 48))
                VStack {
                    ForEach(imageURLs, id: \.self) { url in
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }
    }
}

// MARK: Gestures

extension WordCell {
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global)
            .onEnded { onDragEnd($0) }
            .updating($dragAmount) { dragUpdating($0, &$1, &$2) }
    }
    
    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded { isFront.toggle() }
    }
    
    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { onDoubleTapped() }
    }
    
}

// MARK: View Methods

extension WordCell {
    private func handleEvent(_ event: Event) {
        guard let event = event as? StudyViewEvent else { return }
        switch event {
        case .toFront:
            isFront = true; return
        }
    }
    
    private func onDoubleTapped() {
        if isLocked { return }
        viewModel.updateStudyState(to: .undefined)
    }
    
    private func dragUpdating(_ value: _EndedGesture<DragGesture>.Value, _ state: inout CGSize, _ transaction: inout Transaction) {
        if isLocked { return }
        state.width = value.translation.width
    }
    
    private func onDragEnd(_ value: DragGesture.Value) {
        if isLocked { return }
        if value.translation.width > 0 {
            viewModel.updateStudyState(to: .success)
        } else {
            viewModel.updateStudyState(to: .fail)
        }
    }
}

// MARK: ViewModel

extension WordCell {
    final class ViewModel: ObservableObject {
        @Published var word: Word
        private let frontType: FrontType
        let eventPublisher: PassthroughSubject<Event, Never>
        
        init(word: Word, frontType: FrontType, eventPublisher: PassthroughSubject<Event, Never>) {
            self.word = word
            self.frontType = frontType
            self.eventPublisher = eventPublisher
        }
        
        var frontText: String {
            switch frontType {
            case .meaning:
                return word.meaningText
            case .kanji:
                return word.kanjiText
            }
        }
        
        var frontImageURLs: [URL] {
            switch frontType {
            case .meaning:
                return [word.meaningImageURL]
                    .filter { !$0.isEmpty }
                    .compactMap { URL(string: $0) }
            case .kanji:
                return [word.kanjiImageURL]
                    .filter { !$0.isEmpty }
                    .compactMap { URL(string: $0) }
            }
        }
        
        // frontText를 제외한 두 가지 text에서 빈 text를 제외하고 띄어쓰기
        var backText: String {
            switch frontType {
            case .meaning:
                return [word.ganaText, word.kanjiText]
                    .filter { !$0.isEmpty }
                    .joined(separator: "\n")
            case .kanji:
                return [word.ganaText, word.meaningText]
                    .filter { !$0.isEmpty }
                    .joined(separator: "\n")
            }
        }
        
        var backImageURLs: [URL] {
            switch frontType {
            case .meaning:
                return [word.kanjiImageURL, word.ganaImageURL]
                    .filter { !$0.isEmpty }
                    .compactMap { URL(string: $0) }
            case .kanji:
                return [word.ganaImageURL, word.meaningImageURL]
                    .filter { !$0.isEmpty }
                    .compactMap { URL(string: $0) }
            }
            
        }
        
        func updateStudyState(to state: StudyState) {
            word.studyState = state
            eventPublisher.send(CellEvent.studyStateUpdate(word: word, state: state))
        }
        
        func prefetchImage() {
            guard word.hasImage == true else { return }
            let urls = frontImageURLs + backImageURLs
            let prefetcher = ImagePrefetcher(urls: urls) {
                skippedResources, failedResources, completedResources in
                print("prefetched image: \(completedResources)")
            }
            prefetcher.start()
        }
    }
}

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
    @ObservedObject private var viewModel: ViewModel
    @State private var dragWidth: CGFloat = 0
    @State private var isFront = true
    
    init(word: Word, frontType: FrontType, eventPublisher: PassthroughSubject<Event, Never>) {
        self.viewModel = ViewModel(word: word, frontType: frontType, eventPublisher: eventPublisher)
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
                            if !viewModel.frontText.isEmpty {
                                Text(viewModel.frontText)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 48))
                                    .lineLimit(3)
                            }
                            if !viewModel.frontImageURLs.isEmpty {
                                VStack {
                                    ForEach(viewModel.frontImageURLs, id: \.self) { url in
                                        KFImage(url)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                            }
                        }
                    } else {
                        VStack {
                            if !viewModel.backText.isEmpty {
                                Text(viewModel.backText)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 48))
                                    .lineLimit(3)
                            }
                            if !viewModel.backImageURLs.isEmpty {
                                VStack {
                                    ForEach(viewModel.backImageURLs, id: \.self) { url in
                                        KFImage(url)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                            }
                        }
                    }
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
                            viewModel.updateStudyState(to: .success)
                        } else {
                            viewModel.updateStudyState(to: .fail)
                        }
                    })
                )
                // TODO: 더블탭이랑 탭이랑 같이 쓸 때 더블탭을 위에 놓아야 함(https://stackoverflow.com/questions/58539015/swiftui-respond-to-tap-and-double-tap-with-different-actions)
                .gesture(TapGesture(count: 2).onEnded {
                    viewModel.updateStudyState(to: .undefined)
                })
                .gesture(TapGesture().onEnded {
                    isFront.toggle()
                })
                .onLongPressGesture {
                    // FIXME: this is about view!!! not about logic
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
    
    private func handleEvent(_ event: Event) {
        guard let event = event as? StudyViewEvent else { return }
        switch event {
        case .toFront:
            isFront = true; return
        }
    }
}

extension WordCell {
    final class ViewModel: ObservableObject {
        @Published var word: Word
        private let frontType: FrontType
        private(set) var eventPublisher = PassthroughSubject<Event, Never>()
        
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

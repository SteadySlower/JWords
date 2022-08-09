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
    private let eventPublisher: PassthroughSubject<Event, Never>
    
    init(wordDisplay: Binding<WordDisplay>, eventPublisher: PassthroughSubject<Event, Never>) {
        self.viewModel = ViewModel(wordDisplay: wordDisplay, eventPublisher: eventPublisher)
        self.eventPublisher = eventPublisher
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
                    CellColor(state: $viewModel.wordDisplay.word.studyState)
                    if viewModel.wordDisplay.isFront {
                        VStack {
                            if !viewModel.wordDisplay.frontText.isEmpty {
                                Text(viewModel.wordDisplay.frontText)
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
                            if !viewModel.wordDisplay.backText.isEmpty {
                                Text(viewModel.wordDisplay.backText)
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
                    viewModel.wordDisplay.isFront.toggle()
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
}

extension WordCell {
    final class ViewModel: ObservableObject {
        @Binding var wordDisplay: WordDisplay
        private let eventPublisher: PassthroughSubject<Event, Never>
        
        init(wordDisplay: Binding<WordDisplay>, eventPublisher: PassthroughSubject<Event, Never>) {
            self._wordDisplay = wordDisplay
            self.eventPublisher = eventPublisher
        }
        
        var frontImageURLs: [URL] {
            wordDisplay.frontImageURLs.compactMap { URL(string: $0) }
        }
        
        var backImageURLs: [URL] {
            wordDisplay.backImages.compactMap { URL(string: $0) }
        }
        
        func updateStudyState(to state: StudyState) {
            guard wordDisplay.word.studyState != state else { return }
            wordDisplay.word.studyState = state
            eventPublisher.send(CellEvent.studyStateUpdate(id: wordDisplay.word.id, state: state))
        }
        
        func prefetchImage() {
            guard wordDisplay.hasImage == true else { return }
            let urls = frontImageURLs + backImageURLs
            let prefetcher = ImagePrefetcher(urls: urls) {
                skippedResources, failedResources, completedResources in
                print("prefetched image: \(completedResources)")
            }
            prefetcher.start()
        }
    }
}

//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct StudyWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        var word: Word
        let isLocked: Bool
        let frontType: FrontType
        var studyState: StudyState {
            get {
                word.studyState
            }
            set(newState) {
                word.studyState = newState
            }
        }
        var isFront: Bool = true
        
        init(word: Word, frontType: FrontType = .kanji, isLocked: Bool = false) {
            self.id = word.id
            self.word = word
            self.isLocked = isLocked
            self.frontType = frontType
        }

    }
    
    enum SwipeDirection: Equatable {
        case left, right
    }
    
    enum Action: Equatable {
        case cellTapped
        case cellDoubleTapped
        case cellDrag(direction: SwipeDirection)
        case studyStateResponse(TaskResult<StudyState>)
    }
    
    @Dependency(\.wordClient) var wordClient
    private enum UpdateStudyStateID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                state.isFront.toggle()
                return .none
            case .cellDoubleTapped:
                if state.isLocked { return .none }
                let word = state.word
                return .task {
                    await .studyStateResponse(TaskResult { try await wordClient.studyState(word, .undefined) })
                }.cancellable(id: UpdateStudyStateID.self)
            case .cellDrag(let direction):
                if state.isLocked { return .none }
                let word = state.word
                let newState: StudyState = direction == .left ? .success : .fail
                return .task {
                    await .studyStateResponse(TaskResult { try await wordClient.studyState(word, newState) })
                }.cancellable(id: UpdateStudyStateID.self)
            case let .studyStateResponse(.success(newState)):
                state.studyState = newState
                return .none
            case .studyStateResponse(.failure(_)):
                return .none
            }
        }
    }

}

struct StudyCell: View {
    
    let store: StoreOf<StudyWord>
    
    @GestureState private var dragAmount = CGSize.zero
    
    // gestures
    let dragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .global)
    let tapGesture = TapGesture()
    let doubleTapGesture = TapGesture(count: 2)
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            BaseCell(word: vs.word,
                     frontType: vs.frontType,
                     isFront: vs.isFront,
                     dragAmount: dragAmount)
            .gesture(dragGesture
                .updating($dragAmount) { dragUpdating(vs.isLocked, $0, &$1, &$2) }
                .onEnded { vs.send(.cellDrag(direction: $0.translation.width > 0 ? .left : .right)) }
            )
            .gesture(doubleTapGesture.onEnded { vs.send(.cellDoubleTapped) })
            .gesture(tapGesture.onEnded { vs.send(.cellTapped) })
        }
    }
    
}


// MARK: View Methods

extension StudyCell {
    
    private func dragUpdating(_ isLocked: Bool, _ value: _EndedGesture<DragGesture>.Value, _ state: inout CGSize, _ transaction: inout Transaction) {
        if isLocked { return }
        state.width = value.translation.width
    }
    
}

// MARK: ViewModel

extension StudyCell {
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


struct WordCell_Previews: PreviewProvider {
    
    static var previews: some View {
        StudyCell(
            store: Store(
                initialState: StudyWord.State(word: Word(), frontType: .kanji),
                reducer: StudyWord()._printChanges()
            )
        )
        StudyCell(
            store: Store(
                initialState: StudyWord.State(word: Word(), frontType: .kanji, isLocked: true),
                reducer: StudyWord()._printChanges()
            )
        )
        .previewDisplayName("Locked")
    }
}

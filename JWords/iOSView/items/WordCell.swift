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
        let word: Word
        let isLocked: Bool
        let frontType: FrontType
        var studyState: StudyState
        var isFront: Bool = true
        
        init(word: Word) {
            self.id = word.id
            self.word = word
            self.isLocked = false
            self.frontType = .kanji
            self.studyState = word.studyState
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
        
        static func == (lhs: StudyWord.State, rhs: StudyWord.State) -> Bool {
            lhs.id == rhs.id
            && lhs.isFront == rhs.isFront
            && lhs.studyState == rhs.studyState
        }
    }
    
    enum SwipeDirection: Equatable {
        case left, right
    }
    
    enum Action: Equatable {
        case cellTapped
        case cellDoubleTapped
        case cellDrag(direction: SwipeDirection)
    }
    
    struct Environment {}
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .cellTapped:
            state.isFront.toggle()
            return .none
        case .cellDoubleTapped:
            if state.isLocked { return .none }
            state.studyState = .undefined
            return .none
        case .cellDrag(let direction):
            if state.isLocked { return .none }
            switch direction {
            case .left:
                state.studyState = .success
            case .right:
                state.studyState = .fail
            }
            return .none
        }
    }
}

struct WordCell: View {
    
    let store: StoreOf<StudyWord>
    
    @GestureState private var dragAmount = CGSize.zero
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    
    // gestures
    let dragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .global)
    let tapGesture = TapGesture()
    let doubleTapGesture = TapGesture(count: 2)
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                contentView
                    .gesture(dragGesture
                        .updating($dragAmount) { dragUpdating(vs.isLocked, $0, &$1, &$2) }
                        .onEnded { vs.send(.cellDrag(direction: $0.translation.width > 0 ? .left : .right)) }
                    )
                    .gesture(doubleTapGesture.onEnded { vs.send(.cellDoubleTapped) })
                    .gesture(tapGesture.onEnded { vs.send(.cellTapped) })
            }
            #if os(iOS)
            .onAppear { deviceOrientationChanged() }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in deviceOrientationChanged() }
            #endif
        }
    }
    
}

// MARK: SubViews

extension WordCell {
    
    private var contentView: some View {
        WithViewStore(self.store) { vs in
            ZStack {
                background
                ZStack {
                    cellColor
                    cellFace(isFront: vs.isFront)
                }
                .offset(dragAmount)
            }
            .frame(width: deviceWidth * 0.9)
            .frame(minHeight: vs.word.hasImage ? 200 : 100)
        }
    }
    
    private var background: some View {
        ZStack {
            sizeDecisionView
            HStack {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.red)
            }
            .background { Color.white }
        }
    }
    
    private var cellColor: some View {
        WithViewStore(self.store) { vs in
            Group {
                switch vs.studyState {
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
    
    private func cellFace(isFront: Bool) -> some View {
        
        return WithViewStore(self.store) { vs in
            var text: String {
                isFront ? vs.frontText : vs.backText
            }
            
            var imageURLs: [URL] {
                isFront ? vs.frontImageURLs : vs.backImageURLs
            }
            
            VStack {
                Text(text)
                    .font(.system(size: fontSize(of: text)))
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
    
    private var sizeDecisionView: some View {
        ZStack {
            ZStack {
                cellFace(isFront: true)
                Color.white
            }
            ZStack {
                cellFace(isFront: false)
                Color.white
            }
        }
    }
    
}

// MARK: View Methods

extension WordCell {
    
    private func dragUpdating(_ isLocked: Bool, _ value: _EndedGesture<DragGesture>.Value, _ state: inout CGSize, _ transaction: inout Transaction) {
        if isLocked { return }
        state.width = value.translation.width
    }
    
    private func deviceOrientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.deviceWidth = Constants.Size.deviceWidth
        }
    }
    
    private func fontSize(of text: String) -> CGFloat {
        if text.count <= 10 {
            return 45
        } else if text.count <= 30 {
            return 35
        } else {
            return 30
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

struct WordCell_Previews: PreviewProvider {
    static var previews: some View {
        WordCell(
            store: Store(
                initialState: StudyWord.State(word: WordImpl()),
                reducer: StudyWord()
            )
        )
    }
}

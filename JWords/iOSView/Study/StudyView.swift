//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct WordList: ReducerProtocol {
    struct State: Equatable {
        let wordBook: WordBook?
        var _words: IdentifiedArrayOf<StudyWord.State> = []
        var setting: StudySetting.State
        var selectedIDs: Set<String> = []
        var toEditWord: Word?
        
        var showEditModal: Bool = false
        var showMoveModal: Bool = false
        var shouldDismiss: Bool = false
        var showSideBar: Bool = false
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
            self.setting = .init(frontMode: wordBook.preferredFrontType)
        }
        
        init(words: [Word]) {
            self.wordBook = nil
            self._words = IdentifiedArray(uniqueElements: words.map { StudyWord.State(word: $0) })
            self.setting = .init()
        }
        
        var isLocked: Bool {
            wordBook == nil && setting.studyMode == .onlyFail
        }
        
        var words: IdentifiedArrayOf<StudyWord.State> {
            switch setting.studyMode {
            case .all: return _words
            case .excludeSuccess: return _words.filter { $0.studyState != .success }
            case .onlyFail: return _words.filter { $0.studyState == .fail }
            }
        }
        
        var toMoveWords: IdentifiedArrayOf<StudyWord.State> {
            if setting.studyViewMode == .selection {
                return _words.filter { selectedIDs.contains($0.id) }
            } else {
                return _words.filter { $0.studyState != .success }
            }
        }
        
    }

    enum Action: Equatable {
        case onAppear
        case wordsResponse(TaskResult<[Word]>)
        case setMoveModal(isPresented: Bool)
        case editButtonTapped
        case setEditModal(isPresented: Bool)
        case setSideBar(isPresented: Bool)
        case randomButtonTapped
        case closeButtonTapped
        case word(id: StudyWord.State.ID, action: StudyWord.Action)
        case sideBar(action: StudySetting.Action)
    }
    
    @Dependency(\.wordClient) var wordClient
    private enum FetchWordsID {}
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.setting, action: /Action.sideBar(action:)) {
            StudySetting()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let wordBook = state.wordBook else { return .none }
                return .task {
                    await .wordsResponse(TaskResult { try await wordClient.words(wordBook) })
                }
                .cancellable(id: FetchWordsID.self)
            case let .wordsResponse(.success(words)):
                state._words = IdentifiedArrayOf(uniqueElements: words.map { StudyWord.State(word: $0, frontType: state.setting.frontType) })
                return .none
            case .wordsResponse(.failure):
                state._words = []
                return .none
            case .setSideBar(let isPresented):
                state.showSideBar = isPresented
                return .none
            case .randomButtonTapped:
                state._words.shuffle()
                return .none
            case .word(let id, let action):
                return .none
            case .sideBar(let action):
                switch action {
                case .setFrontType(_):
                    state._words = IdentifiedArray(uniqueElements: state._words.map { setFrontType($0, type: state.setting.frontType) })
                    return .none
                default:
                    return .none
                }
            default:
                return .none
            }
        }
        .forEach(\._words, action: /Action.word(id:action:)) {
          StudyWord()
        }
    }
    
    private func setFrontType(_ wordState: StudyWord.State, type: FrontType) -> StudyWord.State {
        let word = wordState.word
        return StudyWord.State(word: word, frontType: type)
    }

}

struct StudyView: View {
    
    let store: StoreOf<WordList>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEachStore(
                      self.store.scope(state: \.words, action: WordList.Action.word(id:action:))
                    ) {
                      WordCell(store: $0)
                    }
                }
            }
            .navigationTitle(vs.wordBook?.title ?? "틀린 단어 모아보기")
            .onAppear { vs.send(.onAppear) }
            .sideBar(showSideBar: vs.binding(
                get: \.showSideBar,
                send: WordList.Action.setSideBar(isPresented:))
            ) {
                SettingSideBar(store: self.store.scope(state: \.setting, action: WordList.Action.sideBar(action:)))
            }
            .sheet(isPresented: vs.binding(
                get: \.showMoveModal,
                send: WordList.Action.setMoveModal(isPresented:))
            ) {
                // TODO: add move modal
            }
            .sheet(isPresented: vs.binding(
                get: \.showEditModal,
                send: WordList.Action.setEditModal(isPresented:))
            ) {
                // TODO: add edit modal
            }
            #if os(iOS)
            .toolbar { ToolbarItem {
                HStack {
                    Button("랜덤") {
                        vs.send(.randomButtonTapped)
                    }
                    .disabled(vs.setting.studyViewMode != .normal)
                    Button("설정") {
                        vs.send(.setSideBar(isPresented: true))
                    }
                }
            } }
            .toolbar { ToolbarItem(placement: .navigationBarLeading) {
                Button(vs.setting.studyViewMode == .selection ? "이동" : "마감") {
                    vs.send(.setMoveModal(isPresented: true))
                }
                .disabled(vs.wordBook == nil || vs.setting.studyViewMode == .edit)
            } }
            #endif
        }
    }
}

// MARK: ViewModel

extension StudyView {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook?
        @Published private var _words: [Word] = []
        @Published var studyMode: StudyMode = .all {
            didSet {
                eventPublisher.send(StudyViewEvent.toFront)
            }
        }
        @Published var frontType: FrontType {
            didSet {
                eventPublisher.send(StudyViewEvent.toFront)
            }
        }
        
        // 단어 모아보기 + 틀린 단어만 복습일 때는 cell 잠금
        var isCellLocked: Bool {
            return wordBook == nil && studyMode == .onlyFail
        }
        
        // 선택해서 이동 기능 관련 variables
        @Published var studyViewMode: StudyViewMode = .normal {
            didSet {
                if studyViewMode == .selection {
                    eventPublisher.send(StudyViewEvent.toFront)
                    selectionDict = [String : Bool]()
                }
            }
        }
        
        @Published private(set) var selectionDict = [String : Bool]()
        
        func isSelected(_ word: Word) -> Bool {
            selectionDict[word.id, default: false]
        }
        
        // 단어 Edit 관련 properties
        var toEditWord: Word?
        
        private(set) var eventPublisher = PassthroughSubject<Event, Never>()
        
        private let wordService: WordService
        
        var words: [Word] {
            switch studyMode {
            case .all: return _words
            case .excludeSuccess: return _words.filter { $0.studyState != .success }
            case .onlyFail: return _words.filter { $0.studyState == .fail }
            }
        }
        
        var toMoveWords: [Word] {
            if studyViewMode == .selection {
                return _words.filter { selectionDict[$0.id, default: false] }
            } else {
                return _words.filter { $0.studyState != .success }
            }
        }
        
        init(wordBook: WordBook, wordService: WordService) {
            self.wordBook = wordBook
            self.wordService = wordService
            self.frontType = wordBook.preferredFrontType
        }
        
        init(words: [Word], wordService: WordService) {
            self.wordBook = nil
            self._words = words
            self.wordService = wordService
            self.frontType = .kanji
        }
        

        func fetchWords() {
            guard let wordBook = wordBook else { return }
            wordService.getWords(wordBook: wordBook) { [weak self] words, error in
                if let error = error {
                    print("디버그: \(error.localizedDescription)")
                }
                guard let words = words else { return }
                self?._words = words
            }
        }
        
        func shuffleWords() {
            _words.shuffle()
            eventPublisher.send(StudyViewEvent.toFront)
        }
        
        func handleEvent(_ event: Event) {
            if let event = event as? CellEvent {
                switch event {
                case .studyStateUpdate(let word, let state):
                    updateStudyState(word: word, state: state)
                }
            } else if let event = event as? WordInputViewEvent {
                switch event {
                case .wordEdited(let word):
                    editWord(word: word)
                }
            } else {
                return
            }
        }
        
        func toggleSelection(_ word: Word) {
            selectionDict[word.id, default: false].toggle()
        }
        
        private func updateStudyState(word: Word, state: StudyState) {
            wordService.updateStudyState(word: word, newState: state) { [weak self] error in
                // FIXME: handle error
                if let error = error { print(error); return }
                guard let self = self else { return }
                    
                guard let index = self._words.firstIndex(where: { $0.id == word.id }) else { return }
                self._words[index].studyState = state
            }
        }
        
        private func editWord(word: Word) {
            guard let index = _words.firstIndex(where: { word.id == $0.id }) else { return }
            _words[index] = word
        }
    }
}


struct StudyView_Previews: PreviewProvider {
    
    private static let mockWords: [Word] = [
        Word(), Word(), Word(), Word(), Word(), Word(), Word(), Word()
    ]
    
    static var previews: some View {
        NavigationView {
            StudyView(
                store: Store(
                    initialState: WordList.State(words: mockWords),
                    reducer: WordList()._printChanges()
                )
            )
        }
        .previewDisplayName("words")
        NavigationView {
            StudyView(
                store: Store(
                    initialState: WordList.State(wordBook: .mock),
                    reducer: WordList()._printChanges()
                )
            )
        }
        .previewDisplayName("word book")
    }
}


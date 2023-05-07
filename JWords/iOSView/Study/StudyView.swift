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
        var isLoading: Bool = false
        
        // state for cells of each StudyViewMode
        var _words: IdentifiedArrayOf<StudyWord.State> = []
        var editWords: IdentifiedArrayOf<EditWord.State> = []
        var selectionWords: IdentifiedArrayOf<SelectionWord.State> = []
        
        // state for side bar and modals
        var setting: StudySetting.State
        var toEditWord: InputWord.State?
        var moveWords: MoveWords.State?
        var addUnit: AddingUnit.State?
        
        var showEditModal: Bool = false
        var showMoveModal: Bool = false
        var showAddModal: Bool = false
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
        
        var words: IdentifiedArrayOf<StudyWord.State> {
            guard !isLoading else { return [] }
            switch setting.studyMode {
            case .all:
                return _words
            case .excludeSuccess:
                return _words.filter { $0.studyState != .success }
            case .onlyFail:
                return _words.filter { $0.studyState == .fail }
            }
        }
        
        var toMoveWords: [Word] {
            if setting.studyViewMode == .selection {
                return selectionWords.filter { $0.isSelected }.map { $0.word }
            } else {
                return _words.filter { $0.studyState != .success }.map { $0.word }
            }
        }
        
        fileprivate mutating func editCellTapped(id: String) {
            guard let word = _words.filter({ $0.id == id }).first?.word else { return }
            toEditWord = InputWord.State(word: word)
            showEditModal = true
        }
        
        fileprivate mutating func clearEdit() {
            editWords = []
            toEditWord = nil
            setting.studyViewMode = .normal
        }
        
        fileprivate mutating func clearMove() {
            moveWords = nil
            selectionWords = []
            setting.studyViewMode = .normal
        }
        
        fileprivate mutating func editWord(word: Word) throws {
            guard let index = _words.index(id: word.id) else {
                throw AppError.noMatchingWord(id: word.id)
            }
            _words[index] = StudyWord.State(word: word, frontType: setting.frontType)
            setting.studyViewMode = .normal
        }
        
    }

    enum Action: Equatable {
        case onAppear
        case wordsResponse(TaskResult<[Word]>)
        case imageFetchResponse(TaskResult<Bool>)
        case setMoveModal(isPresented: Bool)
        case editButtonTapped
        case setEditModal(isPresented: Bool)
        case setAddModal(isPresented: Bool)
        case setSideBar(isPresented: Bool)
        case randomButtonTapped
        case closeButtonTapped
        case word(id: StudyWord.State.ID, action: StudyWord.Action)
        case editWords(id: EditWord.State.ID, action: EditWord.Action)
        case editWord(action: InputWord.Action)
        case moveWords(action: MoveWords.Action)
        case addUnit(action: AddingUnit.Action)
        case selectionWords(id: SelectionWord.State.ID, action: SelectionWord.Action)
        case sideBar(action: StudySetting.Action)
        case dismiss
    }
    
    @Dependency(\.wordClient) var wordClient
    @Dependency(\.imageClient) var imageClient
    private enum FetchWordsID {}
    private enum FetchImagesID {}
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.setting, action: /Action.sideBar(action:)) {
            StudySetting()
        }
        Reduce { state, action in
            switch action {
            // actions for the list it self
            case .onAppear:
                state.isLoading = true
                guard let wordBook = state.wordBook else {
                    let words = state._words.map { $0.word }
                    return .task {
                        await .imageFetchResponse(TaskResult { try await imageClient.prefetchImages(words) })
                    }
                    .cancellable(id: FetchImagesID.self)
                }
                return .task {
                    await .wordsResponse(TaskResult { try await wordClient.words(wordBook) })
                }
                .cancellable(id: FetchWordsID.self)
            case let .wordsResponse(.success(words)):
                state._words = IdentifiedArrayOf(uniqueElements: words.map { StudyWord.State(word: $0, frontType: state.setting.frontType) })
                return .task {
                    await .imageFetchResponse(TaskResult { try await imageClient.prefetchImages(words) })
                }
                .cancellable(id: FetchImagesID.self)
            case .imageFetchResponse:
                state.isLoading = false
                return .none
            case .wordsResponse(.failure):
                state._words = []
                return .none
            case .randomButtonTapped:
                state._words.shuffle()
                return .none
            case .editWords(let id, let action):
                switch action {
                case .cellTapped:
                    state.editCellTapped(id: id)
                }
                return .none
            // actions for side bar and modal presentation
            case .setSideBar(let isPresented):
                state.showSideBar = isPresented
                return .none
            case .setEditModal(let isPresent):
                state.showEditModal = isPresent
                return .none
            case .setMoveModal(let isPresent):
                if isPresent {
                    guard let fromBook = state.wordBook else { return .none }
                    state.moveWords = MoveWords.State(fromBook: fromBook, toMoveWords: state.toMoveWords)
                } else {
                    state.clearMove()
                }
                state.showMoveModal = isPresent
                return .none
            case .setAddModal(let isPresent):
                state.showAddModal = isPresent
                if isPresent {
//                    state.addUnit = AddingUnit.State(set: <#T##StudySet#>)
                } else {
                    state.addUnit = nil
                }
                return .none
            // actions from side bar and modals
            case .editWord(let editWordAction):
                switch editWordAction {
                case let .editWordResponse(.success(word)):
                    do {
                        try state.editWord(word: word)
                    } catch {
                        print(error)
                        return .none
                    }
                    state.clearEdit()
                    state.showEditModal = false
                default:
                    break
                }
                return .none
            case .moveWords(let action):
                switch action {
                case .moveWordsResponse(.success):
                    return .task { .dismiss }
                default:
                    break
                }
                return .none
            case .sideBar(let action):
                switch action {
                case .setFrontType(_):
                    state._words = IdentifiedArray(uniqueElements: state._words.map { StudyWord.State(word: $0.word, frontType: state.setting.frontType) })
                    return .none
                case .setStudyViewMode(let mode):
                    switch mode {
                    case .normal:
                        state.editWords = []
                        state.selectionWords = []
                    case .edit:
                        state.editWords = IdentifiedArrayOf(uniqueElements: state.words.map { EditWord.State(word: $0.word, frontType: state.setting.frontType) })
                    case .selection:
                        state.selectionWords = IdentifiedArrayOf(uniqueElements: state.words.map { SelectionWord.State(word: $0.word, frontType: state.setting.frontType) })
                    }
                    state.showSideBar = false
                    return .none
                case .setStudyMode(let mode):
                    switch mode {
                    case .all, .excludeSuccess:
                        state._words = IdentifiedArray(
                            uniqueElements: state._words
                                .map { StudyWord.State(word: $0.word, isLocked: false) })
                    case .onlyFail:
                        state._words = IdentifiedArray(
                            uniqueElements: state._words
                                .map { StudyWord.State(word: $0.word, isLocked: true) })
                    }
                    state.showSideBar = false
                    return .none
                }
            default:
                return .none
            }
        }
        .forEach(\._words, action: /Action.word(id:action:)) {
            StudyWord()
        }
        .forEach(\.editWords, action: /Action.editWords(id:action:)) {
            EditWord()
        }
        .forEach(\.selectionWords, action: /Action.selectionWords(id:action:)) {
            SelectionWord()
        }
        .ifLet(\.toEditWord, action: /Action.editWord(action:)) {
            InputWord()
        }
        .ifLet(\.moveWords, action: /Action.moveWords(action:)) {
            MoveWords()
        }
        .ifLet(\.addUnit, action: /Action.addUnit(action:)) {
            AddingUnit()
        }
    }
    
}

struct StudyView: View {
    
    let store: StoreOf<WordList>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                if vs.setting.studyViewMode == .normal {
                    LazyVStack(spacing: 32) {
                        ForEachStore(
                          self.store.scope(state: \.words, action: WordList.Action.word(id:action:))
                        ) {
                            StudyCell(store: $0)
                        }
                    }
                } else if vs.setting.studyViewMode == .edit {
                    LazyVStack(spacing: 32) {
                        ForEachStore(
                            self.store.scope(state: \.editWords, action: WordList.Action.editWords(id:action:))
                        ) {
                            EditCell(store: $0)
                        }
                    }
                } else if vs.setting.studyViewMode == .selection {
                    LazyVStack(spacing: 32) {
                        ForEachStore(
                            self.store.scope(state: \.selectionWords, action: WordList.Action.selectionWords(id:action:))
                        ) {
                            SelectionCell(store: $0)
                        }
                    }
                }
            }
            .loadingView(vs.isLoading)
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
                IfLetStore(self.store.scope(state: \.moveWords, action: WordList.Action.moveWords(action:))) {
                    WordMoveView(store: $0)
                }
            }
            .sheet(isPresented: vs.binding(
                get: \.showEditModal,
                send: WordList.Action.setEditModal(isPresented:))
            ) {
                IfLetStore(self.store.scope(state: \.toEditWord, action: WordList.Action.editWord(action:))) {
                    WordInputView(store: $0)
                }
            }
            .sheet(isPresented: vs.binding(
                get: \.showAddModal,
                send: WordList.Action.setAddModal(isPresented:))
            ) {
                IfLetStore(self.store.scope(state: \.addUnit, action: WordList.Action.addUnit(action:))) {
                    StudyUnitAddView(store: $0)
                }
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
                HStack {
                    Button(vs.setting.studyViewMode == .selection ? "이동" : "마감") {
                        vs.send(.setMoveModal(isPresented: true))
                    }
                    .disabled(vs.wordBook == nil || vs.setting.studyViewMode == .edit)
                    Button("+") { vs.send(.setAddModal(isPresented: true)) }
                }
            } }
            #endif
        }
    }
}

struct StudyView_Previews: PreviewProvider {
    
    private static let mockWords: [Word] = {
        var result = [Word]()
        for i in 0..<10 {
            result.append(Word(index: i))
        }
        return result
    }()
    
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
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
        NavigationView {
            StudyView(
                store: Store(
                    initialState: WordList.State(wordBook: .mock),
                    reducer: WordList()._printChanges()
                )
            )
        }
        .previewDisplayName("word book")
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}


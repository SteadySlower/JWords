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
        var set: StudySet?
        var isLoading: Bool = false
        let navigationTitle: String
        
        // state for cells of each StudyViewMode
        var _words: IdentifiedArrayOf<StudyWord.State> = []
        var editWords: IdentifiedArrayOf<EditWord.State> = []
        var selectionWords: IdentifiedArrayOf<SelectionWord.State> = []
        var deleteWords: IdentifiedArrayOf<DeleteWord.State> = []
        
        // state for side bar and modals
        var setting: StudySetting.State
        var editSet: InputBook.State?
        var toEditWord: AddingUnit.State?
        var moveWords: MoveWords.State?
        var addUnit: AddingUnit.State?
        
        var showEditSetModal: Bool {
            editSet != nil
        }
        
        var showEditModal: Bool {
            toEditWord != nil
        }
        var showMoveModal: Bool {
            moveWords != nil
        }
        var showAddModal: Bool {
            addUnit != nil
        }
        var showSideBar: Bool = false
        
        init(set: StudySet) {
            self.set = set
            self.navigationTitle = set.title
            self.setting = .init(frontMode: set.preferredFrontType)
        }
        
        init(units: [StudyUnit]) {
            self.set = nil
            self.navigationTitle = "틀린 단어 모아보기"
            self._words = IdentifiedArray(uniqueElements: units.map { StudyWord.State(unit: $0) })
            self.setting = .init(showEditButtons: false)
        }
        
        init(kanji: Kanji, units: [StudyUnit]) {
            self.set = nil
            self.navigationTitle = "\(kanji.kanjiText ?? "")가 쓰이는 단어"
            self._words = IdentifiedArray(uniqueElements: units.map { StudyWord.State(unit: $0) })
            self.setting = .init(showEditButtons: false)
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
        
        var toMoveWords: [StudyUnit] {
            if setting.studyViewMode == .selection {
                return selectionWords.filter { $0.isSelected }.map { $0.unit }
            } else {
                return _words.filter { $0.studyState != .success }.map { $0.unit }
            }
        }
        
        fileprivate mutating func editCellTapped(id: String) {
            guard let word = _words.filter({ $0.id == id }).first?.unit else { return }
            toEditWord = AddingUnit.State(mode: .editUnit(unit: word))
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
        
        fileprivate mutating func editWord(word: StudyUnit) throws {
            guard let index = _words.index(id: word.id) else {
                throw AppError.noMatchingWord(id: word.id)
            }
            _words[index] = StudyWord.State(unit: word, frontType: setting.frontType)
            setting.studyViewMode = .normal
        }
        
        fileprivate mutating func onFrontTypeChanged() {
            _words = IdentifiedArray(uniqueElements: _words.map { StudyWord.State(unit: $0.unit, frontType: setting.frontType) })
        }
        
        fileprivate mutating func onStudyViewModeChanged() {
            let mode = setting.studyViewMode
            switch mode {
            case .normal:
                editWords = []
                selectionWords = []
            case .edit:
                editWords = IdentifiedArrayOf(uniqueElements: words.map { EditWord.State(unit: $0.unit, frontType: setting.frontType) })
            case .selection:
                selectionWords = IdentifiedArrayOf(uniqueElements: words.map { SelectionWord.State(unit: $0.unit, frontType: setting.frontType) })
            }
        }
        
        fileprivate mutating func onStudyModeChanged() {
            let mode = setting.studyMode
            switch mode {
            case .all, .excludeSuccess:
                _words = IdentifiedArray(
                    uniqueElements: _words
                        .map { StudyWord.State(unit: $0.unit, isLocked: false) })
            case .onlyFail:
                _words = IdentifiedArray(
                    uniqueElements: _words
                        .map { StudyWord.State(unit: $0.unit, isLocked: true) })
            }
        }
        
    }

    enum Action: Equatable {
        case onAppear
        case setMoveModal(isPresented: Bool)
        case editButtonTapped
        case setEditSetModal(isPresented: Bool)
        case setEditModal(isPresented: Bool)
        case setAddModal(isPresented: Bool)
        case setSideBar(isPresented: Bool)
        case randomButtonTapped
        case closeButtonTapped
        case word(id: StudyWord.State.ID, action: StudyWord.Action)
        case editWords(id: EditWord.State.ID, action: EditWord.Action)
        case deleteWords(id: DeleteWord.State.ID, action: DeleteWord.Action)
        case editSet(action: InputBook.Action)
        case editWord(action: AddingUnit.Action)
        case moveWords(action: MoveWords.Action)
        case addUnit(action: AddingUnit.Action)
        case selectionWords(id: SelectionWord.State.ID, action: SelectionWord.Action)
        case sideBar(action: StudySetting.Action)
        case onWordsMoved(from: StudySet)
        case dismiss
    }
    
    let ud = UserDefaultClient.shared
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.setting, action: /Action.sideBar(action:)) {
            StudySetting()
        }
        Reduce { state, action in
            switch action {
            // actions for the list it self
            case .onAppear:
                state.isLoading = true
                guard let set = state.set else {
                    state.isLoading = false
                    return .none
                }
                let units = try! cd.fetchUnits(of: set)
                state._words = IdentifiedArrayOf(
                    uniqueElements: units.map {
                        StudyWord.State(unit: $0, frontType: state.setting.frontType)
                    })
                state.isLoading = false
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
            case .setEditSetModal(let isPresented):
                if isPresented {
                    guard let set = state.set else { return .none }
                    state.editSet = InputBook.State(set: set)
                } else {
                    state.editSet = nil
                }
                return .none
            case .setEditModal(let isPresent):
                if !isPresent { state.toEditWord = nil }
                return .none
            case .setMoveModal(let isPresent):
                if isPresent {
                    guard let fromBook = state.set else { return .none }
                    state.moveWords = MoveWords.State(fromBook: fromBook, toMoveWords: state.toMoveWords)
                } else {
                    state.clearMove()
                }
                return .none
            case .setAddModal(let isPresent):
                guard let set = state.set else { return .none }
                if isPresent {
                    state.addUnit = AddingUnit.State(mode: .insert(set: set))
                } else {
                    state.addUnit = nil
                }
                return .none
            // actions from side bar and modals
            case .editSet(let action):
                switch action {
                case .setEdited(let set):
                    state.set = set
                    return .task { .setEditSetModal(isPresented: false) }
                case .cancelButtonTapped:
                    return .task { .setEditSetModal(isPresented: false) }
                default:
                    return .none
                }
            case .editWord(let action):
                switch action {
                case .unitEdited(let unit):
                    guard let index = state._words.index(id: unit.id) else { return .none }
                    let newState = StudyWord.State(unit: unit, frontType: state.setting.frontType)
                    state._words.update(newState, at: index)
                    state.setting.studyViewMode = .normal
                    return .task { .setEditModal(isPresented: false) }
                case .cancelButtonTapped:
                    return .task { .setEditModal(isPresented: false) }
                default:
                    return .none
                }
            case .addUnit(let action):
                switch action {
                case let .unitAdded(unit):
                    var words = state._words.map { $0.unit }
                    words.append(unit)
                    state._words = IdentifiedArray(
                        uniqueElements: words
                            .map { StudyWord.State(unit: $0, isLocked: false) })
                    return .task { .setAddModal(isPresented: false) }
                case .cancelButtonTapped:
                    return .task { .setAddModal(isPresented: false) }
                default:
                    return .none
                }
            case .moveWords(let action):
                switch action {
                case .onMoved(let set):
                    return .task { .onWordsMoved(from: set) }
                case .cancelButtonTapped:
                    return .task { .setMoveModal(isPresented: false) }
                default:
                    return .none
                }
            case .sideBar(let action):
                switch action {
                case .setFrontType(_):
                    state.onFrontTypeChanged()
                case .setStudyViewMode(_):
                    state.onStudyViewModeChanged()
                case .setStudyMode(_):
                    state.onStudyModeChanged()
                case .wordBookEditButtonTapped:
                    state.showSideBar = false
                    return .task { .setEditSetModal(isPresented: true) }
                case .wordAddButtonTapped:
                    state.showSideBar = false
                    return .task { .setAddModal(isPresented: true) }
                }
                state.showSideBar = false
                return .none
            case .onWordsMoved:
                return .task { .dismiss }
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
        .forEach(\.deleteWords, action: /Action.deleteWords(id:action:)) {
            DeleteWord()
        }
        .ifLet(\.toEditWord, action: /Action.editWord(action:)) {
            AddingUnit()
        }
        .ifLet(\.moveWords, action: /Action.moveWords(action:)) {
            MoveWords()
        }
        .ifLet(\.addUnit, action: /Action.addUnit(action:)) {
            AddingUnit()
        }
        .ifLet(\.editSet, action: /Action.editSet(action:)) {
            InputBook()
        }
    }
    
}

struct StudyView: View {
    
    let store: StoreOf<WordList>
    
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
            .navigationTitle(vs.navigationTitle)
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
                    StudyUnitAddView(store: $0)
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
            .sheet(isPresented: vs.binding(
                get: \.showEditSetModal,
                send: WordList.Action.setEditSetModal(isPresented:))
            ) {
                IfLetStore(self.store.scope(state: \.editSet, action: WordList.Action.editSet(action:))) {
                    WordBookAddModal(store: $0)
                }
            }
            #if os(iOS)
            .toolbar { ToolbarItem {
                HStack {
                    Button("♻️") {
                        vs.send(.randomButtonTapped)
                    }
                    .disabled(vs.setting.studyViewMode != .normal)
                    Button("⚙️") {
                        vs.send(.setSideBar(isPresented: !vs.showSideBar))
                    }
                }
            } }
            .toolbar { ToolbarItem(placement: .navigationBarLeading) {
                Button(vs.setting.studyViewMode == .selection ? "이동" : "마감") {
                    vs.send(.setMoveModal(isPresented: true))
                }
                .disabled(vs.set == nil || vs.setting.studyViewMode == .edit)
            } }
            #endif
        }
    }
}

struct StudyView_Previews: PreviewProvider {
    
    private static let mockWords: [StudyUnit] = {
        var result = [StudyUnit]()
        for i in 0..<10 {
            result.append(StudyUnit(index: i))
        }
        return result
    }()
    
    static var previews: some View {
        NavigationView {
            StudyView(
                store: Store(
                    initialState: WordList.State(units: mockWords),
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
                    initialState: WordList.State(units: .mock),
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


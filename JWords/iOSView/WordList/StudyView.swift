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
        var kanji: Kanji?
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
        var toEditWord: EditUnit.State?
        var moveWords: MoveWords.State?
        var addUnit: AddUnit.State?
        
        // alert
        var alert: AlertState<Action>?
        
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
        
        // TODO: make another view for kanji
        var isKanjiView: Bool {
            kanji != nil
        }
        
        init(set: StudySet) {
            self.set = set
            self.navigationTitle = set.title
            self.setting = .init(set: set, frontType: set.preferredFrontType)
        }
        
        init(units: [StudyUnit]) {
            self.set = nil
            self.navigationTitle = "틀린 단어 모아보기"
            self._words = IdentifiedArray(uniqueElements: units.map { StudyWord.State(unit: $0) })
            self.setting = .init()
        }
        
        init(kanji: Kanji, units: [StudyUnit]) {
            self.set = nil
            self.kanji = kanji
            self.navigationTitle = "\(kanji.kanjiText)가 쓰이는 단어"
            self._words = IdentifiedArray(uniqueElements: units.map { StudyWord.State(sample: $0) })
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
        
        var toMoveWords: [StudyUnit] {
            if setting.studyViewMode == .selection {
                return selectionWords.filter { $0.isSelected }.map { $0.unit }
            } else {
                return _words.filter { $0.studyState != .success }.map { $0.unit }
            }
        }
        
        fileprivate mutating func editCellTapped(id: String) {
            guard let word = _words.filter({ $0.id == id }).first?.unit else { return }
            toEditWord = EditUnit.State(unit: word)
        }
        
        fileprivate mutating func deleteCellTapped(id: String) {
            guard let word = _words.filter({ $0.id == id }).first?.unit else { return }
            let wordDisplayText = HuriganaConverter.shared.huriToKanjiText(from: word.kanjiText)
            
            alert = AlertState<Action> {
                TextState("\(wordDisplayText)를 현재 단어장에서 삭제합니까?")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
                ButtonState(role: .destructive, action: .deleteUnit(unit: word)) {
                    TextState("삭제")
                }
            } message: {
                TextState("이 단어를 삭제합니다. 다른 단어장에 저장된 같은 단어는 삭제되지 않습니다.")
            }
        }
        
        private mutating func showDeleteUnableAlert() {
            alert = AlertState<Action> {
                TextState("단어 삭제 불가")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("확인")
                }
            } message: {
                TextState("틀린 단어 모아보기에서는 단어를 삭제할 수 없습니다.")
            }
        }
        
        fileprivate mutating func onUnitDeleted(id: String) {
            guard (_words.filter({ $0.id == id }).first?.unit) != nil else { return }
            _words.remove(id: id)
            deleteWords = []
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
                deleteWords = []
            case .edit:
                editWords = IdentifiedArrayOf(uniqueElements: words.map { EditWord.State(unit: $0.unit, frontType: setting.frontType) })
            case .selection:
                selectionWords = IdentifiedArrayOf(uniqueElements: words.map { SelectionWord.State(unit: $0.unit, frontType: setting.frontType) })
            case .delete:
                guard set != nil else {
                    showDeleteUnableAlert()
                    setting.studyViewMode = .normal
                    return
                }
                deleteWords = IdentifiedArrayOf(uniqueElements: words.map { DeleteWord.State(unit: $0.unit, frontType: setting.frontType) })
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
        case deleteUnit(unit: StudyUnit)
        case onUnitDeleted(id: String)
        case editSet(action: InputBook.Action)
        case editWord(EditUnit.Action)
        case moveWords(action: MoveWords.Action)
        case addUnit(AddUnit.Action)
        case selectionWords(id: SelectionWord.State.ID, action: SelectionWord.Action)
        case sideBar(action: StudySetting.Action)
        case onWordsMoved(from: StudySet)
        case alertDismissed
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
            case .deleteWords(let id, let action):
                switch action {
                case .cellTapped:
                    state.deleteCellTapped(id: id)
                }
                return .none
            case .deleteUnit(let unit):
                guard let set = state.set else { return .none }
                try! cd.deleteUnit(unit: unit, from: set)
                return .task { .onUnitDeleted(id: unit.id) }
            case .onUnitDeleted(let id):
                state.onUnitDeleted(id: id)
                return .task { .alertDismissed }
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
                    state.addUnit = AddUnit.State(set: set)
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
                case .edited(let unit):
                    guard let index = state._words.index(id: unit.id) else { return .none }
                    let newState = StudyWord.State(unit: unit, frontType: state.setting.frontType)
                    state._words.update(newState, at: index)
                    state.setting.studyViewMode = .normal
                    return .task { .setEditModal(isPresented: false) }
                case .cancel:
                    return .task { .setEditModal(isPresented: false) }
                default:
                    return .none
                }
            case .addUnit(let action):
                switch action {
                case let .added(unit):
                    var words = state._words.map { $0.unit }
                    if !words.contains(unit) {
                        words.append(unit)
                    }
                    state._words = IdentifiedArray(
                        uniqueElements: words
                            .map { StudyWord.State(unit: $0, isLocked: false) })
                    return .task { .setAddModal(isPresented: false) }
                case .cancel:
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
            case .alertDismissed:
                state.alert = nil
                return .none
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
        .ifLet(\.toEditWord, action: /Action.editWord) {
            EditUnit()
        }
        .ifLet(\.moveWords, action: /Action.moveWords(action:)) {
            MoveWords()
        }
        .ifLet(\.addUnit, action: /Action.addUnit) {
            AddUnit()
        }
        .ifLet(\.editSet, action: /Action.editSet(action:)) {
            InputBook()
        }
    }
    
}

struct StudyView: View {
    
    let store: StoreOf<WordList>
    private let CELL_HORIZONTAL_PADDING: CGFloat = 15
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                if vs.setting.studyViewMode == .normal {
                    LazyVStack(spacing: 32) {
                        if !vs.isKanjiView {
                            ForEachStore(
                              self.store.scope(state: \.words, action: WordList.Action.word(id:action:))
                            ) {
                                StudyCell(store: $0)
                            }
                        } else {
                            ForEachStore(
                              self.store.scope(state: \.words, action: WordList.Action.word(id:action:))
                            ) {
                                StudyCell(store: $0)
                            }
                        }
                    }
                    .padding(.horizontal, CELL_HORIZONTAL_PADDING)
                    .padding(.vertical, 10)
                } else if vs.setting.studyViewMode == .edit {
                    LazyVStack(spacing: 32) {
                        ForEachStore(
                            self.store.scope(state: \.editWords, action: WordList.Action.editWords(id:action:))
                        ) {
                            EditCell(store: $0)
                        }
                    }
                    .padding(.horizontal, CELL_HORIZONTAL_PADDING)
                    .padding(.vertical, 10)
                } else if vs.setting.studyViewMode == .selection {
                    LazyVStack(spacing: 32) {
                        ForEachStore(
                            self.store.scope(state: \.selectionWords, action: WordList.Action.selectionWords(id:action:))
                        ) {
                            SelectionCell(store: $0)
                        }
                    }
                    .padding(.horizontal, CELL_HORIZONTAL_PADDING)
                    .padding(.vertical, 10)
                } else if vs.setting.studyViewMode == .delete {
                    LazyVStack(spacing: 32) {
                        ForEachStore(
                            self.store.scope(state: \.deleteWords, action: WordList.Action.deleteWords(id:action:))
                        ) {
                            DeleteCell(store: $0)
                        }
                    }
                    .padding(.horizontal, CELL_HORIZONTAL_PADDING)
                    .padding(.vertical, 10)
                }
            }
            .withBannerAD()
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
                IfLetStore(self.store.scope(
                    state: \.toEditWord,
                    action: WordList.Action.editWord)
                ) {
                    EditUnitView(store: $0)
                        .padding(.horizontal, 10)
                        .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: vs.binding(
                get: \.showAddModal,
                send: WordList.Action.setAddModal(isPresented:))
            ) {
                IfLetStore(self.store.scope(
                    state: \.addUnit,
                    action: WordList.Action.addUnit)
                ) {
                    AddUnitView(store: $0)
                        .padding(.horizontal, 10)
                        .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: vs.binding(
                get: \.showEditSetModal,
                send: WordList.Action.setEditSetModal(isPresented:))
            ) {
                IfLetStore(self.store.scope(
                    state: \.editSet,
                    action: WordList.Action.editSet(action:))
                ) {
                    WordBookAddModal(store: $0)
                }
            }
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
            #if os(iOS)
            .toolbar { ToolbarItem {
                HStack {
                    Button {
                        vs.send(.setMoveModal(isPresented: true))
                    } label: {
                        Image(systemName: "book.closed")
                            .resizable()
                            .foregroundColor(.black)
                    }
                    .hide(vs.set == nil || vs.setting.studyViewMode == .edit || vs.isKanjiView)
                    Button {
                        vs.send(.randomButtonTapped)
                    } label: {
                        Image(systemName: "shuffle")
                            .resizable()
                            .foregroundColor(vs.setting.studyViewMode == .normal ? .black : .gray)
                    }
                    .disabled(vs.setting.studyViewMode != .normal)
                    .hide(vs.isKanjiView)
                    Button {
                        vs.send(.setSideBar(isPresented: !vs.showSideBar))
                    } label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .foregroundColor(.black)
                    }
                    .hide(vs.isKanjiView)
                }
            } }
            .toolbar(.hidden, for: .tabBar)
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


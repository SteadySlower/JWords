//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

enum StudyMode: Hashable, CaseIterable, Equatable {
    case all, excludeSuccess, onlyFail
    
    var pickerText: String {
        switch self {
        case .all: return "전부"
        case .excludeSuccess: return "O제외"
        case .onlyFail: return "X만"
        }
    }
}

enum StudyViewMode: Hashable, Equatable {
    case normal
    case selection
    case edit
}

struct WordList: ReducerProtocol {
    struct State: Equatable {
        let wordBook: WordBook?
        var _words: IdentifiedArrayOf<StudyWord.State> = []
        var studyMode: StudyMode = .all
        var frontType: FrontType
        var studyViewMode: StudyViewMode = .normal
        var selectedIDs: Set<String> = []
        var toEditWord: Word?
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
            self.frontType = wordBook.preferredFrontType
        }
        
        init(words: [Word]) {
            self.wordBook = nil
            self._words = IdentifiedArray(uniqueElements: words.map { StudyWord.State(word: $0) })
            self.frontType = .kanji
        }
        
        var isLocked: Bool {
            wordBook == nil && studyMode == .onlyFail
        }
        
        var words: IdentifiedArrayOf<StudyWord.State> {
            switch studyMode {
            case .all: return _words
            case .excludeSuccess: return _words.filter { $0.studyState != .success }
            case .onlyFail: return _words.filter { $0.studyState == .fail }
            }
        }
        
        var toMoveWords: IdentifiedArrayOf<StudyWord.State> {
            if studyViewMode == .selection {
                return _words.filter { selectedIDs.contains($0.id) }
            } else {
                return _words.filter { $0.studyState != .success }
            }
        }
        
    }

    enum Action: Equatable {
        case onAppear
        case wordsResponse(TaskResult<[Word]>)
        case moveButtonTapped
        case editButtonTapped
        case studyModeChanged(StudyMode)
        case frontTypeChanged(FrontType)
        case viewModeChanged(StudyViewMode)
        case randomButtonTapped
        case settingButtonTapped
        case closeButtonTapped
    }
    
    @Dependency(\.wordClient) var wordClient
    private enum FetchWordsID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let wordBook = state.wordBook else { return .none }
                return .task {
                    await .wordsResponse(TaskResult { try await wordClient.words(wordBook) })
                }
                .cancellable(id: FetchWordsID.self)
            case let .wordsResponse(.success(words)):
                state._words = IdentifiedArrayOf(uniqueElements: words.map { StudyWord.State(word: $0) })
                return .none
            case .wordsResponse(.failure):
                state._words = []
                return .none
            case .moveButtonTapped:
                return .none
            default:
                return .none
            }

            
            
        }
    }

}

struct StudyView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let dependency: ServiceManager
    
    @State private var showEditModal: Bool = false
    @State private var showMoveModal: Bool = false
    @State private var shouldDismiss: Bool = false
    @State private var showSideBar: Bool = false
    
    init(wordBook: WordBook, dependency: ServiceManager) {
        self._viewModel = StateObject(wrappedValue: ViewModel(wordBook: wordBook, wordService: dependency.wordService))
        self.dependency = dependency
    }
    
    // 틀린 단어 모아보기용
    init(words: [Word], dependency: ServiceManager) {
        self._viewModel = StateObject(wrappedValue: ViewModel(words: words, wordService: dependency.wordService))
        self.dependency = dependency
    }
    
    var body: some View {
        contentView
            .navigationTitle(viewModel.wordBook?.title ?? "틀린 단어 모아보기")
            .onAppear { viewModel.fetchWords() }
            .sheet(isPresented: $showMoveModal,
                   onDismiss: { if shouldDismiss { dismiss() } },
                   content: { WordMoveView(wordBook: viewModel.wordBook!,
                                           toMoveWords: viewModel.toMoveWords,
                                           didClosed: $shouldDismiss,
                                           dependency: dependency) })
            .sheet(isPresented: $showEditModal,
                   onDismiss: { viewModel.toEditWord = nil; viewModel.studyViewMode = .normal },
                   content: { WordInputView(viewModel.toEditWord,
                                            dependency: dependency,
                                            eventPublisher: viewModel.eventPublisher) })
            #if os(iOS)
            .onReceive(viewModel.eventPublisher) { viewModel.handleEvent($0) }
            .toolbar { ToolbarItem { rightToolBarItems } }
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { leftToolBarItems } }
            #endif
    }
    
}

// MARK: SubViews

extension StudyView {
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(viewModel.words, id: \.id) { word in
//                    WordCell(word: word,
//                             frontType: viewModel.frontType,
//                             eventPublisher: viewModel.eventPublisher,
//                             isLocked: viewModel.isCellLocked)
//                            .selectable(nowSelecting: viewModel.studyViewMode == .selection,
//                                        isSelected: viewModel.isSelected(word),
//                                        onTap: { viewModel.toggleSelection(word) })
//                            .editable(nowEditing: viewModel.studyViewMode == .edit) {
//                                viewModel.toEditWord = word
//                                showEditModal = true
//                            }
                }
            }
        }
        .sideBar(showSideBar: $showSideBar) { settingSideBar }
    }
    
    private var settingSideBar: some View {
        
        var studyModePicker: some View {
            Picker("", selection: $viewModel.studyMode) {
                ForEach(StudyMode.allCases, id: \.self) {
                    Text($0.pickerText)
                }
            }
            .pickerStyle(.segmented)
        }
        
        var frontTypePicker: some View {
            Picker("", selection: $viewModel.frontType) {
                ForEach(FrontType.allCases, id: \.self) {
                    Text($0.pickerText)
                }
            }
            .pickerStyle(.segmented)
        }
        
        var viewModePicker: some View {
            Picker("모드", selection: $viewModel.studyViewMode) {
                Text("학습")
                    .tag(StudyViewMode.normal)
                Text("선택")
                    .tag(StudyViewMode.selection)
                Text("수정")
                    .tag(StudyViewMode.edit)
            }
            .pickerStyle(.segmented)
        }
        
        var body: some View {
            VStack {
                Spacer()
                studyModePicker
                    .padding()
                frontTypePicker
                    .padding()
                if viewModel.wordBook != nil {
                    viewModePicker
                        .padding()
                }
                Spacer()
            }
        }
        
        return body
    }
    
    private var rightToolBarItems: some View {
        HStack {
            Button("랜덤") {
                viewModel.shuffleWords()
            }
            .disabled(viewModel.studyViewMode != .normal)
            Button("설정") {
                showSideBar = true
            }
        }
    }
    
    private var leftToolBarItems: some View {
        Button(viewModel.studyViewMode == .selection ? "이동" : "마감") {
            showMoveModal = true
        }
        .disabled(viewModel.wordBook == nil || viewModel.studyViewMode == .edit)
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




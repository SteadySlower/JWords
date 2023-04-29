//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct AddWord: ReducerProtocol {

    struct State: Equatable {
        @BindingState var focusedField: Field?
        var book = SelectWordBook.State()
        var meaning = AddMeaning.State()
        var kanji = AddKanji.State()
        var gana = AddGana.State()
        var isLoading = false
        
        var unableToSave: Bool {
            (book.selectedID == nil)
            || meaning.isEmpty
            || (kanji.isEmpty && gana.isEmpty)
            || isLoading
        }
        
        mutating func updateTextBySample(_ id: String?) {
            if let sample = meaning.samples.first { $0.id == id } {
                kanji.text = sample.kanjiText
                gana.text = sample.ganaText
            } else {
                kanji.text = ""
                gana.text = ""
            }
        }
        
        enum Field: Hashable {
            case meaning, kanji, gana
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case selectWordBook(action: SelectWordBook.Action)
        case addMeaning(action: AddMeaning.Action)
        case addKanji(action: AddKanji.Action)
        case addGana(action: AddGana.Action)
        case saveButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addMeaning(.onTab):
                state.focusedField = .kanji
                return .none
            case let .addMeaning(.updateSelectedID(id)):
                state.updateTextBySample(id)
                return .none
            case let .addKanji(.updateText(text)):
                if state.gana.autoConvert {
                    state.gana.text = text.hiragana
                }
                state.meaning.selectedID = nil
                return .none
            case .addKanji(.onTab):
                state.focusedField = .gana
                return .none
            case .addGana(.onTab):
                state.focusedField = .meaning
                return .none
            case .addGana(.updateText):
                state.meaning.selectedID = nil
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.book, action: /Action.selectWordBook(action:)) {
            SelectWordBook()
        }
        Scope(state: \.meaning, action: /Action.addMeaning(action:)) {
            AddMeaning()
        }
        Scope(state: \.kanji, action: /Action.addKanji(action:)) {
            AddKanji()
        }
        Scope(state: \.gana, action: /Action.addGana(action:)) {
            AddGana()
        }
    }

}

struct MacAddWordView: View {
    
    let store: StoreOf<AddWord>
    @FocusState var focusedField: AddWord.State.Field?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                WordBookPicker(store: store.scope(
                    state: \.book,
                    action: AddWord.Action.selectWordBook(action:))
                )
                MeaningField(store: store.scope(
                    state: \.meaning,
                    action: AddWord.Action.addMeaning(action:))
                )
                .focused($focusedField, equals: .meaning)
                KanjiField(store: store.scope(
                    state: \.kanji,
                    action: AddWord.Action.addKanji(action:))
                )
                .focused($focusedField, equals: .kanji)
                GanaField(store: store.scope(
                    state: \.gana,
                    action: AddWord.Action.addGana(action:))
                )
                .focused($focusedField, equals: .gana)
                if vs.isLoading {
                    ProgressView()
                } else {
                    Button {
                        vs.send(.saveButtonTapped)
                    } label: {
                        Text("저장")
                    }
                    .disabled(vs.unableToSave)
                    .keyboardShortcut(.return, modifiers: [.control])
                }
            }
            .onAppear { vs.send(.onAppear) }
            .synchronize(vs.binding(\.$focusedField), self.$focusedField)
        }

    }
    
}


struct MacAddWordView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddWordView(
            store: Store(
                initialState: AddWord.State(),
                reducer: AddWord()._printChanges()
            )
        )
    }
}

// MARK: ViewModel
extension MacAddWordView {
    final class ViewModel: BaseViewModel {
        // Properties
        
        private let wordService: WordService
        private let sampleService: SampleService
        private let wordBookService: WordBookService
        
        // 단어 내용 입력 관련 properties
        @Published var meaningText: String = ""
        @Published private(set) var meaningImage: InputImageType?
        @Published var ganaText: String = ""
        @Published private(set) var ganaImage: InputImageType?
        @Published var kanjiText: String = ""
        @Published private(set) var kanjiImage: InputImageType?
        
        // 저장할 단어장 관련 properties
        @Published private(set) var wordBook: WordBook?
        
        @Published private(set) var bookList: [WordBook] = []
        @Published var selectedBookID: String? {
            // TODO: refactor
            didSet {
                addWordRepository.updateWordBook(bookList.first(where: { $0.id == selectedBookID }))
            }
        }
        @Published private(set) var wordCount: Int?
        @Published private(set) var didBooksFetched: Bool = false
        @Published private(set) var isUploading: Bool = false
        
        var wordBookPickerDefaultText: String {
            if didBooksFetched && !bookList.isEmpty {
                return "단어장을 선택해주세요"
            } else if didBooksFetched && bookList.isEmpty {
                return "단어장 리스트 불러오기 실패"
            } else {
                return "단어장 불러오는 중..."
            }
        }
        
        // 예시 관련 properties
        @Published private(set) var samples: [Sample] = []
        @Published private(set) var isAutoSearch: Bool = true
        @Published var selectedSampleID: String?
        
        var isSaveButtonUnable: Bool {
            return (meaningText.isEmpty && meaningImage == nil) || (ganaText.isEmpty && ganaImage == nil && kanjiText.isEmpty && kanjiImage == nil) || isUploading || (selectedBookID == nil)
        }
        
        private let addWordRepository: AddWordRepository
        
        // initializer
        init(_ dependency: ServiceManager,
             _ addWordRepository: AddWordRepository = RepositoryManager.addWordRepository) {
            self.wordService = dependency.wordService
            self.wordBookService = dependency.wordBookService
            self.sampleService = dependency.sampleService
            self.addWordRepository = addWordRepository
            super.init()
            configure()
        }
        
        // public methods
        
        func getWordBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                if let error = error {
                    print("디버그: \(error.localizedDescription)")
                    self?.didBooksFetched = true
                    return
                }
                guard let wordBooks = wordBooks else { return }
                self?.bookList = wordBooks
                self?.didBooksFetched = true
            }
        }
        
        func saveWord() {
            clearSamples()
            addWordRepository.saveWord()
        }
        
        
        // 이미지 관련
        
        func image(of: InputType) -> InputImageType? {
            switch of {
            case .meaning:
                return meaningImage
            case .gana:
                return ganaImage
            case .kanji:
                return kanjiImage
            }
        }
        
        // text 관련 repository 연결함수
        
        func updateText(of type: InputType, _ text: String) {
            addWordRepository.updateText(type, text)
        }
        
        func updateAutoConvert(_ autoConvertMode: Bool) {
            addWordRepository.updateAutoConvertMode(autoConvertMode)
        }
        
        // image 관련 repository 연결함수
        
        func addImageButtonTapped(in inputType: InputType) {
            addWordRepository.updateImage(inputType)
        }
        
        func imageTapped(in inputType: InputType) {
            addWordRepository.clearImage(inputType)
        }
        
        // 샘플 관련 repository 연결 함수
        
        func updateAutoSearch(_ isAutoSearch: Bool) {
            self.isAutoSearch = isAutoSearch
        }
        
        func getExamples(_ query: String) {
            guard !query.isEmpty else { return }
            selectedSampleID = nil
            sampleService.getSamplesByMeaning(query) { [weak self] examples, error in
                if let error = error { print(error); return }
                guard let examples = examples else { print("examples are nil"); return }
                // example의 이미지는 View에 보여줄 수 없으므로 일단 image 있는 것은 필터링
                self?.samples = examples
                                .filter({ !$0.hasImage })
                                .sorted { ex1, ex2 in
                                    if !ex1.kanjiText.isEmpty && ex2.kanjiText.isEmpty {
                                        return true
                                    } else {
                                        return false
                                    }
                                }
                self?.selectedSampleID = examples.first?.id
            }
        }
        
        private func clearSamples() {
            samples = []
        }
        
    }
}

extension MacAddWordView.ViewModel {
    
    func configure() {
        
        $selectedSampleID
            .removeDuplicates()
            .map { [weak self] id in self?.samples.first { $0.id == id } }
            .sink { [weak self] in self?.addWordRepository.updateSample($0) }
            .store(in: &subscription)
        
        // receive state from repository
        addWordRepository
            .$wordBook
            .assign(to: &$wordBook)
        addWordRepository
            .$wordCount
            .assign(to: &$wordCount)
        addWordRepository
            .$meaningText
            .assign(to: &$meaningText)
        addWordRepository
            .$kanjiText
            .assign(to: &$kanjiText)
        addWordRepository
            .$ganaText
            .assign(to: &$ganaText)
        addWordRepository
            .$meaningImage
            .assign(to: &$meaningImage)
        addWordRepository
            .$kanjiImage
            .assign(to: &$kanjiImage)
        addWordRepository
            .$ganaImage
            .assign(to: &$ganaImage)
        addWordRepository
            .$isLoading
            .assign(to: &$isUploading)
        addWordRepository
            .$usedSample
            .map { $0?.id }
            .assign(to: &$selectedSampleID)
    }
    
}

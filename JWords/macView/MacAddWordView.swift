//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine

struct MacAddWordView: View {
    
    @FocusState private var editFocus: InputType?
    
    @ObservedObject private var viewModel: ViewModel
    
    init(_ dependency: ServiceManager) {
        self.viewModel = ViewModel(dependency)
    }
    
    var body: some View {
        contentView
            .onAppear { viewModel.getWordBooks() }
            .onChange(of: viewModel.meaningText) { moveCursorWhenTab($0) }
            .onChange(of: viewModel.kanjiText) { moveCursorWhenTab($0) }
            .onChange(of: viewModel.ganaText) { moveCursorWhenTab($0) }
    }
    
}

// MARK: SubViews
extension MacAddWordView {
    
    private var contentView: some View {
        ScrollView {
            VStack {
                wordBookPicker
                ForEach(InputType.allCases, id: \.self) { type in
                    VStack {
                        textField(type)
                            .focused($editFocus, equals: type)
                        ImageField(inputType: type,
                                   image: viewModel.image(of: type),
                                   addImageButtonTapped: { viewModel.addImageButtonTapped(in: $0) },
                                   imageTapped: { viewModel.imageTapped(in: $0) })
                    }
                }
                saveButton
            }
        }
        .padding(.top, 50)
    }
    
    private var wordBookPicker: some View {
        HStack {
            Picker("", selection: $viewModel.selectedBookID) {
                Text(viewModel.wordBookPickerDefaultText)
                    .tag(nil as String?)
                ForEach(viewModel.bookList, id: \.id) { book in
                    Text(book.title)
                        .tag(book.id as String?)
                }
            }
            Text("단어 수: \(viewModel.wordCount ?? 0)개")
                .hide(viewModel.selectedBookID == nil)
        }
        .padding()
    }
    
    private func textField(_ type: InputType)
    -> some View {
        
        var text: Binding<String> {
            switch type {
            case .meaning: return $viewModel.meaningText
            case .kanji: return $viewModel.kanjiText
            case .gana: return $viewModel.ganaText
            }
        }
        
        return VStack {
            WordAddField(title: "\(type.description) 입력", text: text)
            if type == .meaning {
                HStack {
                    AutoSearchToggle { viewModel.updateAutoSearch($0) }
                    SamplePicker(samples: viewModel.samples, selected: viewModel.selectedSample) { viewModel.handleSamplePickerAction($0) }
                }
                .padding(.horizontal)
            } else if type == .gana {
                AutoConvertToggle { viewModel.updateAutoConvert($0) }
            }
        }
    }
    
    private var saveButton: some View {
        Group {
            if viewModel.isUploading {
                ProgressView()
            } else {
                Button {
                    viewModel.saveWord()
                    editFocus = .meaning
                } label: {
                    Text("저장")
                }
                .disabled(viewModel.isSaveButtonUnable)
                .keyboardShortcut(.return, modifiers: [.control])
            }
        }
    }
    
    

    
}

// MARK: View Methods
// TODO: View Method 중에서 비지니스 로직은 VM으로 이동하기

extension MacAddWordView {
    
    // tab을 눌렀을 때 field 이동하는 것은 비지니스 로직이 아님!
    private func moveCursorWhenTab(_ text: String) {
        guard text.contains("\t") else { return }
        guard let nowCursor = editFocus else { return }
        let removed = text.filter { $0 != "\t" }
        switch nowCursor {
        case .meaning:
            viewModel.meaningText = removed
            viewModel.getExamples(removed)
            editFocus = .kanji
            return
        case .kanji:
            viewModel.kanjiText = removed
            editFocus = .gana
            return
        case .gana:
            viewModel.ganaText = removed
            editFocus = .meaning
            return
        }
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
        @Published private(set) var selectedSample: Sample?
        
        func onSamplePicked(_ sample: Sample?) {
            self.selectedSample = sample
        }
        
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
            addWordRepository.saveWord(selectedSample)
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
    
        
        func handleSamplePickerAction(_ action: SamplePicker.Action) {
            switch action {
            case .picked(let sample):
                self.selectedSample = sample
                if let sample = sample { addWordRepository.updateText(with: sample) }
            case .cancelled:
                addWordRepository.updateText(.kanji, "")
                addWordRepository.updateText(.gana, "")
            }
        }
        
        func getExamples(_ query: String) {
            guard !query.isEmpty else { return }
            selectedSample = nil
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
                self?.selectedSample = examples.first
            }
        }
        
        private func clearSamples() {
            samples = []
        }
        
    }
}

extension MacAddWordView.ViewModel {
    
    func configure() {
        
        // send event to repository
        $meaningText
            .removeDuplicates()
            .sink { [weak self] in self?.addWordRepository.updateText(.meaning, $0) }
            .store(in: &subscription)
        $kanjiText
            .removeDuplicates()
            .sink { [weak self] in self?.addWordRepository.updateText(.kanji, $0) }
            .store(in: &subscription)
        $ganaText
            .removeDuplicates()
            .sink { [weak self] in self?.addWordRepository.updateText(.gana, $0) }
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
            .isLoading
            .assign(to: &$isUploading)
    }
    
}

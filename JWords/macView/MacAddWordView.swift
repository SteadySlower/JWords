//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine

#if os(iOS)
import UIKit
typealias PasteBoardType = UIPasteboard
#elseif os(macOS)
import Cocoa
typealias PasteBoardType = NSPasteboard
#endif

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
                        textField(type) { viewModel.updateText($0, $1) }
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
        .background {
            sampleCancelButton
            sampleUpButton
            sampleDownButton
        }
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
    
    private func textField(_ type: InputType,
                           onTextChange: (InputType, String) -> Void)
    -> some View {
        VStack {
            WordAddField(inputType: type) { viewModel.updateText($0, $1) }
            if type == .meaning {
                HStack {
                    AutoSearchToggle { viewModel.updateAutoSearch($0) }
                    SamplePicker(samples: viewModel.samples,
                                 samplePicked: { viewModel.selectedSample = $0 },
                                 selectedSample: viewModel.selectedSample)
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
    
    
    private var sampleCancelButton: some View {
        Button {
            viewModel.cancelExampleSelection()
        } label: {
                
        }
        .keyboardShortcut(.escape, modifiers: [.command])
        .opacity(0)
    }
    
    private var sampleUpButton: some View {
        Button {
            viewModel.sampleUp()
        } label: {
                
        }
        .keyboardShortcut(.upArrow, modifiers: [.command])
        .opacity(0)
    }
    
    private var sampleDownButton: some View {
        Button {
            viewModel.sampleDown()
        } label: {
                
        }
        .keyboardShortcut(.downArrow, modifiers: [.command])
        .opacity(0)
    }
    
}

// MARK: View Methods
// TODO: View Method 중에서 비지니스 로직은 VM으로 이동하기

extension MacAddWordView {
    
    // tab을 눌렀을 때 field 이동하는 것은 비지니스 로직이 아님!
    private func moveCursorWhenTab(_ text: String) {
        guard text.contains("\t") else { return }
        guard let nowCursor = editFocus else { return }
        let removed = text.filter { $0 == "\t" }
        switch nowCursor {
        case .meaning:
            viewModel.updateText(.meaning, removed)
            viewModel.getExamples()
            editFocus = .kanji
            return
        case .kanji:
            viewModel.updateText(.kanji, removed)
            editFocus = .gana
            return
        case .gana:
            viewModel.updateText(.gana, removed)
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
        @Published private(set) var meaningText: String = ""
        @Published private(set) var meaningImage: InputImageType?
        @Published private(set) var ganaText: String = ""
        @Published private(set) var ganaImage: InputImageType?
        @Published private(set) var kanjiText: String = ""
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
        @Published var selectedSample: Sample?
        @Published var selectedSampleID: String? = nil {
            didSet {
                if selectedSampleID != nil {
                    updateTextWithExample()
                }
            }
        }
        
        private var didSampleUsed: Bool {
            guard let selectedSample = selectedSample else { return false }
            return selectedSample.meaningText == meaningText
                && selectedSample.ganaText == ganaText
                && selectedSample.kanjiText == kanjiText ? true : false
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
        
        func updateText(_ type: InputType, _ text: String) {
            addWordRepository.updateText(type, text)
        }
        
        func updateAutoConvert(_ autoConvertMode: Bool) {
            addWordRepository.updateAutoConvertMode(autoConvertMode)
        }
        
        
        // 샘플 관련 repository 연결 함수
        
        func updateAutoSearch(_ isAutoSearch: Bool) {
            self.isAutoSearch = isAutoSearch
        }
        
        func addImageButtonTapped(in inputType: InputType) {
            addWordRepository.updateImage(inputType)
        }
        
        func imageTapped(in inputType: InputType) {
            addWordRepository.clearImage(inputType)
        }
        
        func getExamples() {
            guard !meaningText.isEmpty else { return }
            selectedSampleID = nil
            sampleService.getSamplesByMeaning(meaningText) { [weak self] examples, error in
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
                if !examples.isEmpty { self?.selectedSampleID = self?.samples[0].id }
            }
        }
        
        func cancelExampleSelection() {
            selectedSampleID = nil
            kanjiText = ""
            ganaText = ""
        }
        
        func sampleUp() {
            guard !samples.isEmpty else { return }
            let nowIndex = samples.firstIndex(where: { $0.id == selectedSampleID }) ?? 0
            let nextIndex = (nowIndex + 1) % samples.count
            selectedSampleID = samples[nextIndex].id
        }
        
        func sampleDown() {
            guard !samples.isEmpty else { return }
            let nowIndex = samples.firstIndex(where: { $0.id == selectedSampleID }) ?? 0
            let nextIndex = (nowIndex - 1) >= 0 ? (nowIndex - 1) : (samples.count - 1)
            selectedSampleID = samples[nextIndex].id
        }
        
        private func clearSamples() {
            samples = []
            selectedSampleID = nil
        }
        
        private func updateTextWithExample() {
            guard let selectedSample = selectedSample else {
//                clearInputs()
                return
            }
            meaningText = selectedSample.meaningText
            ganaText = selectedSample.ganaText
            kanjiText = selectedSample.kanjiText
        }
    }
}

extension MacAddWordView.ViewModel {
    
    func configure() {
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

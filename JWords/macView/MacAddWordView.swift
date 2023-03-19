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
            .onChange(of: viewModel.meaningText) { onMeaningChange($0) }
            .onChange(of: viewModel.kanjiText) { onKanjiChange($0) }
            .onChange(of: viewModel.ganaText) { onGanaChange($0) }
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
                        textField(for: type)
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
            copyAndPasteButton
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
    
    private func textField(for inputType: InputType) -> some View {
        var bindingText: Binding<String> {
            switch inputType {
            case .meaning: return $viewModel.meaningText
            case .gana: return $viewModel.ganaText
            case .kanji: return $viewModel.kanjiText
            }
        }
        
        var overlapCheckButton: some View {
            Button {
                viewModel.checkIfOverlap()
            } label: {
                Text(viewModel.overlapCheckButtonTitle)
            }
            .disabled(viewModel.isOverlapped != nil || viewModel.isCheckingOverlap)
        }
        
        var autoSearchToggle: some View {
            Toggle("자동 검색", isOn: $viewModel.isAutoFetchSamples)
                .keyboardShortcut("f", modifiers: [.command])
        }
        
        var samplePicker: some View {
            Picker("", selection: $viewModel.selectedSampleID) {
                Text(viewModel.samples.isEmpty ? "검색결과 없음" : "미선택")
                    .tag(nil as String?)
                ForEach(viewModel.samples, id: \.id) { sample in
                    Text(sample.description)
                        .tag(sample.id as String?)
                }
            }
        }
        
        var body: some View {
            VStack {
                Text("\(inputType.description) 입력")
                    .font(.system(size: 20))
                TextEditor(text: bindingText)
                    .font(.system(size: 30))
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
                if inputType == .meaning {
                    HStack {
//                        overlapCheckButton
                        autoSearchToggle
                            .padding(.leading, 5)
                        samplePicker
                    }
                    .padding(.horizontal)
                } else if inputType == .gana {
                    Toggle("한자 -> 가나 자동 변환", isOn: $viewModel.isAutoConvert)
                }
            }
        }
        
        return body
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
    
    private var copyAndPasteButton: some View {
        Button {
//            copyAndPaste()
        } label: {
                
        }
        .keyboardShortcut("v", modifiers: [.command])
        .opacity(0)
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
    
    private func onMeaningChange(_ text: String) {
        moveCursorWhenTab(text)
    }
    
    private func onKanjiChange(_ text: String) {
        moveCursorWhenTab(text)
        viewModel.autoConvert(text)
    }
    
    private func onGanaChange(_ text: String) {
        moveCursorWhenTab(text)
        viewModel.trimPastedText(text)
    }
    
    private func moveCursorWhenTab(_ text: String) {
        guard text.contains("\t") else { return }
        guard let nowCursor = editFocus else { return }
        switch nowCursor {
        case .meaning:
            viewModel.meaningText.removeAll(where: { $0 == "\t"})
            viewModel.getExamples()
            editFocus = .kanji
            return
        case .kanji:
            viewModel.kanjiText.removeAll(where: { $0 == "\t"})
            editFocus = .gana
            return
        case .gana:
            viewModel.ganaText.removeAll(where: { $0 == "\t"})
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
        
        private var subscriptions = [AnyCancellable]()
        
        // 단어 내용 입력 관련 properties
        @Published var meaningText: String = "" {
            didSet {
                isOverlapped = nil
            }
        }
        @Published private(set) var meaningImage: InputImageType?
        @Published var ganaText: String = ""
        @Published private(set) var ganaImage: InputImageType?
        @Published var kanjiText: String = ""
        @Published private(set) var kanjiImage: InputImageType?
        
        // 저장할 단어장 관련 properties
        @Published var wordBook: WordBook?
        
        @Published private(set) var bookList: [WordBook] = []
        @Published var selectedBookID: String? {
            didSet {
                countWords(in: selectedBookID)
            }
        }
        @Published var wordCount: Int?
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
        @Published var isAutoFetchSamples: Bool = true
        @Published var selectedSampleID: String? = nil {
            didSet {
                if selectedSampleID != nil {
                    updateTextWithExample()
                }
            }
        }
        private var selectedSample: Sample? {
            return samples.first(where: { $0.id == selectedSampleID })
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
        
        @Published private(set) var isCheckingOverlap: Bool = false
        @Published private(set) var isOverlapped: Bool? = nil
        
        var overlapCheckButtonTitle: String {
            if isCheckingOverlap {
                return "중복 검사중"
            }
            guard let isOverlapped = isOverlapped else {
                return "중복체크"
            }
            return isOverlapped ? "중복됨" : "중복 아님"
        }
        
        // 한자 -> 가나 auto convert
        @Published var isAutoConvert: Bool = true
        
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
            trimTexts()
            isUploading = true
            guard let wordBookID = selectedBookID else {
                // TODO: handle error
                print("선택된 단어장이 없어서 저장할 수 없음")
                isUploading = false
                return
            }
            let wordInput = WordInputImpl(wordBookID: wordBookID, meaningText: meaningText, meaningImage: meaningImage, ganaText: ganaText, ganaImage: ganaImage, kanjiText: kanjiText, kanjiImage: kanjiImage)
            // example이 있는지 확인하고 example과 동일한지 확인하고
                // 동일하면 example의 used에 + 1
                // 동일하지 않으면 새로운 example 추가한다.
            if didSampleUsed,
               let selectedSample = selectedSample {
                sampleService.addOneToUsed(of: selectedSample)
            } else if !wordInput.hasImage {
                sampleService.saveSample(wordInput: wordInput)
            }
            clearInputs()
            clearExamples()
            wordService.saveWord(wordInput: wordInput) { [weak self] error in
                // TODO: handle error
                if let error = error { print("디버그: \(error)"); return }
                self?.isUploading = false
                self?.wordCount = (self?.wordCount ?? 0) + 1
            }
        }
        
        func checkIfOverlap() {
            isCheckingOverlap = true
            // TODO: handle error
            guard let selectedWordBook = bookList.first(where: { $0.id == selectedBookID }) else {
                print("선택된 단어장이 없어서 검색할 수 없음")
                isCheckingOverlap = false
                return
            }
            wordBookService.checkIfOverlap(in: selectedWordBook, meaningText: meaningText) { [weak self] isOverlapped, error in
                if let error = error {
                    self?.isCheckingOverlap = false
                    print("디버그: \(error)")
                    return
                }
                self?.isOverlapped = isOverlapped ?? false
                self?.isCheckingOverlap = false
            }
        }
        
        // 네이버 사전에서 복사-붙여넣기할 때 "히라가나 [한자]" 형태로 된 텍스트 가나-한자로 구분
        func trimPastedText(_ input: String) {
            guard input.contains("[") else { return }
            var strings = input.split(separator: " ")
            guard strings.count >= 2 else { return }
            strings[0] = strings[0].filter { $0 != "-" } // 장음표시 제거
            strings[1] = strings[1].filter { !["[", "]"].contains($0) }
            ganaText = String(strings[0])
            kanjiText = String(strings[1])
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
        
        func addImageButtonTapped(in inputType: InputType) {
            switch inputType {
            case .meaning:
                addWordRepository.updateMeaningImage()
            case .gana:
                addWordRepository.updateGanaImage()
            case .kanji:
                addWordRepository.updateKanjiImage()
            }
        }
        
        func imageTapped(in inputType: InputType) {
            switch inputType {
            case .meaning:
                addWordRepository.clearMeaningImage()
            case .gana:
                addWordRepository.clearGanaImage()
            case .kanji:
                addWordRepository.clearKanjiImage()
            }
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
        
        // 한자 -> 가나 auto convert
        func autoConvert(_ kanji: String) {
            if !isAutoConvert { return }
            ganaText = kanji.hiragana
        }
        
        private func countWords(in wordBookID: String?) {
            guard let id = wordBookID else {
                wordCount = nil
                return
            }
            
            guard let wordBook = bookList.first(where: { $0.id == id }) else { return }
            
            wordBookService.countWords(in: wordBook) { [weak self] count, error in
                if let error = error { print(error); return }
                guard let count = count else { print("No count in wordbook: \(wordBook.id)"); return }
                self?.wordCount = count
            }
        }
        
        private func trimTexts() {
            meaningText = meaningText.lStrip()
            meaningText = meaningText.rStrip()
            kanjiText = kanjiText.lStrip()
            kanjiText = kanjiText.rStrip()
            ganaText = ganaText.lStrip()
            ganaText = ganaText.rStrip()
        }
        
        private func clearInputs() {
            meaningText = ""
            meaningImage = nil
            ganaText = ""
            ganaImage = nil
            kanjiText = ""
            kanjiImage = nil
        }
        
        private func clearExamples() {
            samples = []
            selectedSampleID = nil
        }
        
        private func updateTextWithExample() {
            guard let selectedSample = selectedSample else {
                clearInputs()
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
            .wordBook
            .weakAssign(to: \.wordBook, on: self)
        
        addWordRepository
            .meaningImage
            .weakAssign(to: \.meaningImage, on: self)
        
        addWordRepository
            .kanjiImage
            .weakAssign(to: \.kanjiImage, on: self)
        
        addWordRepository
            .ganaImage
            .weakAssign(to: \.ganaImage, on: self)
    }
    
}

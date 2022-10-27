//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

#if os(iOS)
import UIKit
typealias PasteBoardType = UIPasteboard
#elseif os(macOS)
import Cocoa
typealias PasteBoardType = NSPasteboard
#endif

struct MacAddWordView: View {
    // MARK: Enum
    enum InputType: Hashable {
        case meaning, gana, kanji
        
        var description: String {
            switch self {
            case .meaning: return "뜻"
            case .gana: return "가나"
            case .kanji: return "한자"
            }
        }
    }
    
    private let viewModel: ViewModel
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(dependency)
    }
    
    var body: some View {
        ContentView()
            .environmentObject(viewModel)
    }
    
}

// MARK: ContentView
extension MacAddWordView {
    struct ContentView: View {
        // MARK: Properties
        @EnvironmentObject private var viewModel: ViewModel
        @FocusState private var editFocus: InputType?
        
        // MARK: Body
        var body: some View {
            ScrollView {
                VStack {
                    WordBookPickerView()
                    VStack {
                        TextInputView(inputType: .meaning)
                            .focused($editFocus, equals: .meaning)
                        ImageInputView(inputType: .meaning)
                    }
                    .padding(.bottom)
                    VStack {
                        TextInputView(inputType: .kanji)
                            .focused($editFocus, equals: .kanji)
                        ImageInputView(inputType: .kanji)
                    }
                    VStack {
                        TextInputView(inputType: .gana)
                            .focused($editFocus, equals: .gana)
                        ImageInputView(inputType: .gana)
                    }
                    SaveButton { editFocus = .meaning }
                }
                .padding(.top, 50)
                .onAppear { viewModel.getWordBooks() }
                .onChange(of: viewModel.meaningText) { moveCursorToKanjiWhenTap($0) }
                .onChange(of: viewModel.kanjiText) { viewModel.autoConvert($0) }
                .onChange(of: viewModel.kanjiText) { moveCursorToGanaWhenTap($0) }
                .onChange(of: viewModel.ganaText) { viewModel.trimPastedText($0) }
            }
        }
        
        private func moveCursorToKanjiWhenTap(_ text: String) {
            guard let last = text.last else { return }
            if last == "\t" {
                viewModel.meaningText.removeLast()
                editFocus = .kanji
            }
        }
        
        private func moveCursorToGanaWhenTap(_ text: String) {
            guard let last = text.last else { return }
            if last == "\t" {
                viewModel.kanjiText.removeLast()
                editFocus = .gana
            }
        }
    }
}

// MARK: SubViews
extension MacAddWordView {
    struct WordBookPickerView: View {
        @EnvironmentObject private var viewModel: ViewModel
        
        var body: some View {
            Picker("", selection: $viewModel.selectedBookID) {
                Text(viewModel.wordBookPickerDefaultText)
                    .tag(nil as String?)
                ForEach(viewModel.bookList, id: \.id) { book in
                    Text(book.title)
                        .tag(book.id as String?)
                }
            }
            .padding()
        }
    }
    
    struct TextInputView: View {
        private let inputType: InputType
        @EnvironmentObject private var viewModel: ViewModel
        
        init(inputType: InputType) {
            self.inputType = inputType
        }
        
        var bindingText: Binding<String> {
            switch inputType {
            case .meaning: return $viewModel.meaningText
            case .gana: return $viewModel.ganaText
            case .kanji: return $viewModel.kanjiText
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
                        OverlapCheckButton()
                        SearchExampleButton()
                        ExamplePicker()
                    }
                    .padding(.horizontal)
                } else if inputType == .kanji {
                    Toggle("한자 -> 가나 자동 변환", isOn: $viewModel.isAutoConvert)
                }
            }
        }
        
        private struct OverlapCheckButton: View {
            @EnvironmentObject private var viewModel: ViewModel
            
            var body: some View {
                Button {
                    viewModel.checkIfOverlap()
                } label: {
                    Text(viewModel.overlapCheckButtonTitle)
                }
                .disabled(viewModel.isOverlapped != nil || viewModel.isCheckingOverlap)
            }
        }
        
        private struct SearchExampleButton: View {
            @EnvironmentObject private var viewModel: ViewModel
            
            var body: some View {
                Button {
                    viewModel.getExamples()
                } label: {
                    Text("찾기")
                }
                .disabled(viewModel.meaningText.isEmpty)
            }
        }
        
        private struct ExamplePicker: View {
            @EnvironmentObject private var viewModel: ViewModel
            
            var body: some View {
                Picker("", selection: $viewModel.selectedSampleID) {
                    Text(viewModel.samples.isEmpty ? "검색결과 없음" : "미선택")
                        .tag(nil as String?)
                    ForEach(viewModel.samples, id: \.id) { example in
                        Text("뜻: \(example.meaningText)\n가나: \(example.ganaText)\n한자: \(example.kanjiText)")
                            .tag(example.id as String?)
                    }
                }
            }
        }
    }
    
    struct ImageInputView: View {
        private let inputType: InputType
        @EnvironmentObject private var viewModel: ViewModel
        
        private var image: InputImageType? {
            switch inputType {
            case .meaning: return viewModel.meaningImage
            case .gana: return viewModel.ganaImage
            case .kanji: return viewModel.kanjiImage
            }
        }
        
        private var pasteBoardImage: InputImageType? {
            let pb = PasteBoardType.general
            #if os(iOS)
            guard let image = pb.image else { return nil }
            #elseif os(macOS)
            let type = PasteBoardType.PasteboardType.tiff
            guard let imgData = pb.data(forType: type) else { return nil }
            let image = InputImageType(data: imgData)
            #endif
            return image
        }
        
        init(inputType: InputType) {
            self.inputType = inputType
        }
        
        var body: some View {
            if let image = image {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                    .onTapGesture { viewModel.clearImageInput(inputType) }
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                    .onTapGesture { viewModel.clearImageInput(inputType) }
                #endif
            } else {
                Button {
                    viewModel.insertImage(of: inputType, image: pasteBoardImage)
                } label: {
                    Text("\(inputType.description) 이미지")
                }
            }
        }
    }
    
    struct SaveButton: View {
        @EnvironmentObject private var viewModel: ViewModel
        private let saveButtonTapped: () -> Void
        
        init(saveButtonTapped: @escaping () -> Void) {
            self.saveButtonTapped = saveButtonTapped
        }
        
        var body: some View {
            if viewModel.isUploading {
                ProgressView()
            } else {
                Button {
                    viewModel.saveWord()
                    saveButtonTapped()
                } label: {
                    Text("저장")
                }
                .disabled(viewModel.isSaveButtonUnable)
                .keyboardShortcut(.return, modifiers: [.command])
            }
        }
    }
}

// MARK: ViewModel
extension MacAddWordView {
    final class ViewModel: ObservableObject {
        // Properties
        
        private let wordService: WordService
        private let sampleService: SampleService
        private let wordBookService: WordBookService
        
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
        @Published private(set) var bookList: [WordBook] = []
        @Published var selectedBookID: String?
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
        @Published var selectedSampleID: String? = nil {
            didSet {
                updateTextWithExample()
            }
        }
        private var selectedSample: Sample? {
            return samples.first(where: { $0.id == selectedSampleID })
        }
        
        private var didExampleUsed: Bool {
            guard let selectedSample = selectedSample else { return false }
            return selectedSample.meaningText == meaningText
                && selectedSample.ganaText == ganaText
                && selectedSample.kanjiText == kanjiText ? true : false
        }
        
        var isSaveButtonUnable: Bool {
            return (meaningText.isEmpty && meaningImage == nil) || (ganaText.isEmpty && ganaImage == nil && kanjiText.isEmpty && kanjiImage == nil) || isUploading
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
        
        // initializer
        init(_ dependency: Dependency) {
            self.wordService = dependency.wordService
            self.wordBookService = dependency.wordBookService
            self.sampleService = dependency.sampleService
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
                self?.bookList = wordBooks.filter { $0.closed != true }
                self?.didBooksFetched = true
            }
        }
        
        func saveWord() {
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
            if didExampleUsed,
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
        
        func insertImage(of inputType: InputType, image: InputImageType?) {
            switch inputType {
            case .meaning:
                meaningImage = image
            case .gana:
                ganaImage = image
            case .kanji:
                kanjiImage = image
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
        
        func clearImageInput(_ inputType: InputType) {
            switch inputType {
            case .meaning:
                meaningImage = nil
            case .gana:
                ganaImage = nil
            case .kanji:
                kanjiImage = nil
            }
        }
        
        func getExamples() {
            sampleService.getSamples(meaningText) { [weak self] examples, error in
                if let error = error { print(error); return }
                guard let examples = examples else { print("examples are nil"); return }
                // example의 이미지는 View에 보여줄 수 없으므로 일단 image 있는 것은 필터링
                self?.samples = examples.filter({ !$0.hasImage })
                if !examples.isEmpty { self?.selectedSampleID = examples[0].id }
            }
        }
        
        // 한자 -> 가나 auto convert
        func autoConvert(_ kanji: String) {
            if !isAutoConvert { return }
            ganaText = kanji.hiragana
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

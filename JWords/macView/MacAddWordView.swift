//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

#warning("여기 ios에서도 돌아가도록 바꾸기")

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
                        TextInputView(inputType: .gana)
                            .focused($editFocus, equals: .gana)
                        ImageInputView(inputType: .gana)
                    }
                    VStack {
                        TextInputView(inputType: .kanji)
                            .focused($editFocus, equals: .kanji)
                        ImageInputView(inputType: .kanji)
                    }
                    SaveButton()
                }
                .padding(.top, 50)
                .onAppear { viewModel.getWordBooks() }
                .onChange(of: viewModel.meaningText) { moveCursorToGanaWhenTap($0) }
                .onChange(of: viewModel.ganaText) { moveCursorToKanjiWhenTap($0) }
                .onChange(of: viewModel.ganaText) { viewModel.trimPastedText($0) }
            }
        }
        
        private func moveCursorToGanaWhenTap(_ text: String) {
            guard let last = text.last else { return }
            if last == "\t" {
                viewModel.meaningText.removeLast()
                editFocus = .gana
            }
        }
        
        private func moveCursorToKanjiWhenTap(_ text: String) {
            guard let last = text.last else { return }
            if last == "\t" {
                viewModel.ganaText.removeLast()
                editFocus = .kanji
            }
        }

    }
}

// MARK: SubViews
extension MacAddWordView {
    struct WordBookPickerView: View {
        @EnvironmentObject private var viewModel: ViewModel
        
        var body: some View {
            if viewModel.didBooksFetched && !viewModel.bookList.isEmpty {
                Picker(selection: $viewModel.selectedBookIndex, label: Text("선택된 단어장:")) {
                    ForEach(0..<viewModel.bookList.count, id: \.self) { index in
                        Text(viewModel.bookList[index].title)
                    }
                }
                .padding()
            }
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
        
        var body: some View {
            if viewModel.isUploading {
                ProgressView()
            } else {
                Button {
                    viewModel.saveWord()
                } label: {
                    Text("저장")
                }
                .disabled(viewModel.isSaveButtonUnable)
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
        @Published var bookList: [WordBook] = []
        @Published var selectedBookIndex = 0
        @Published var didBooksFetched: Bool = false
        @Published var isUploading: Bool = false
        
        private var selectedBook: WordBook {
            bookList[selectedBookIndex]
        }
        
        // 예시 관련 properties
        @Published var samples: [Sample] = []
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
        
        @Published var isCheckingOverlap: Bool = false
        @Published var isOverlapped: Bool? = nil
        
        var overlapCheckButtonTitle: String {
            if isCheckingOverlap {
                return "중복 검사중"
            }
            guard let isOverlapped = isOverlapped else {
                return "중복체크"
            }
            return isOverlapped ? "중복됨" : "중복 아님"
        }
        
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
                    return
                }
                guard let wordBooks = wordBooks else { return }
                self?.bookList = wordBooks
                self?.didBooksFetched = true
            }
        }
        
        func saveWord() {
            isUploading = true
            let wordInput = WordInputImpl(wordBookID: selectedBook.id, meaningText: meaningText, meaningImage: meaningImage, ganaText: ganaText, ganaImage: ganaImage, kanjiText: kanjiText, kanjiImage: kanjiImage)
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
            wordBookService.checkIfOverlap(in: selectedBook, meaningText: meaningText) { [weak self] isOverlapped, error in
                if let error = error { print("디버그: \(error)"); return }
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

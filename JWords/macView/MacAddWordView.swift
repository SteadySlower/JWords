//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI


#if os(macOS)
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
    
    var body: some View {
        ContentView()
            .environmentObject(ViewModel())
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
                        TextInputView(inputType: .meaning, editFocus: $editFocus)
                        ImageInputView(inputType: .meaning)
                    }
                    .padding(.bottom)
                    VStack {
                        TextInputView(inputType: .gana, editFocus: $editFocus)
                        ImageInputView(inputType: .gana)
                    }
                    VStack {
                        TextInputView(inputType: .kanji, editFocus: $editFocus)
                        ImageInputView(inputType: .kanji)
                    }
                    SaveButton()
                }
                .padding(.top, 50)
                .onAppear { viewModel.getWordBooks() }
                .onChange(of: viewModel.meaningText) { newValue in
                    guard let last = newValue.last else { return }
                    if last == "\t" {
                        viewModel.meaningText.removeLast()
                        editFocus = .gana
                    }
                }
                .onChange(of: viewModel.ganaText) { newValue in
                    guard let last = newValue.last else { return }
                    if last == "\t" {
                        viewModel.ganaText.removeLast()
                        editFocus = .kanji
                    }
                }
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
        private var editFocus: FocusState<InputType?>.Binding
        
        init(inputType: InputType, editFocus: FocusState<InputType?>.Binding) {
            self.inputType = inputType
            self.editFocus = editFocus
        }
        
        var bindingText: Binding<String> {
            switch inputType {
            case .meaning: return $viewModel.meaningText
            case .gana: return $viewModel.ganaText
            case .kanji: return $viewModel.kanjiText
            }
        }
        
        var body: some View {
            Text("\(inputType.description) 입력")
                .font(.system(size: 20))
            TextEditor(text: bindingText)
                .font(.system(size: 30))
                .frame(height: Constants.Size.deviceHeight / 8)
                .padding(.horizontal)
                .focused(editFocus, equals: inputType)
            if inputType == .meaning {
                OverlapCheckButton
            }
        }
        
        private var OverlapCheckButton: some View {
            Button {
                viewModel.checkIfOverlap()
            } label: {
                Text(viewModel.overlapCheckButtonTitle)
            }
            .disabled(viewModel.isOverlapped != nil || viewModel.isCheckingOverlap)
        }
    }
    
    struct ImageInputView: View {
        private let inputType: InputType
        @EnvironmentObject private var viewModel: ViewModel
        
        private var image: NSImage? {
            switch inputType {
            case .meaning: return viewModel.meaningImage
            case .gana: return viewModel.ganaImage
            case .kanji: return viewModel.kanjiImage
            }
        }
        
        private var pasteBoardImage: NSImage? {
            let pb = NSPasteboard.general
            let type = NSPasteboard.PasteboardType.tiff
            guard let imgData = pb.data(forType: type) else { return nil }
            return NSImage(data: imgData)
        }
        
        init(inputType: InputType) {
            self.inputType = inputType
        }
        
        var body: some View {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                    .onTapGesture { viewModel.clearImageInput(inputType) }
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

// MARK: Methods
extension MacAddWordView {
    
}

// MARK: ViewModel
extension MacAddWordView {
    final class ViewModel: ObservableObject {
        // Properties
        @Published var meaningText: String = "" {
            didSet {
                isOverlapped = nil
            }
        }
        @Published private(set) var meaningImage: NSImage?
        @Published var ganaText: String = ""
        @Published private(set) var ganaImage: NSImage?
        @Published var kanjiText: String = ""
        @Published private(set) var kanjiImage: NSImage?
        
        @Published var bookList: [WordBook] = []
        @Published var selectedBookIndex = 0
        @Published var didBooksFetched: Bool = false
        @Published var isUploading: Bool = false
        
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
        
        // public methods
        
        func getWordBooks() {
            WordService.getWordBooks { [weak self] wordBooks, error in
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
            let wordInput = WordInput(meaningText: meaningText, meaningImage: meaningImage, ganaText: ganaText, ganaImage: ganaImage, kanjiText: kanjiText, kanjiImage: kanjiImage)
            guard let selectedBookID = bookList[selectedBookIndex].id else { print("디버그: 선택된 단어장 없음"); return }
            
            clearInputs()
            WordService.saveWord(wordInput: wordInput, wordBookID: selectedBookID) { [weak self] error in
                if let error = error { print("디버그: \(error)"); return }
                self?.isUploading = false
            }
        }
        
        func checkIfOverlap() {
            isCheckingOverlap = true
            guard let selectedBookID = bookList[selectedBookIndex].id else { print("디버그: 선택된 단어장 없음"); return }
            WordService.checkIfOverlap(wordBookID: selectedBookID, meaningText: meaningText) { [weak self] isOverlapped, error in
                if let error = error { print("디버그: \(error)"); return }
                self?.isOverlapped = isOverlapped ?? false
                self?.isCheckingOverlap = false
            }
        }
        
        func insertImage(of inputType: InputType, image: NSImage?) {
            switch inputType {
            case .meaning:
                meaningImage = image
            case .gana:
                ganaImage = image
            case .kanji:
                kanjiImage = image
            }
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
        
        private func clearInputs() {
            meaningText = ""
            meaningImage = nil
            ganaText = ""
            ganaImage = nil
            kanjiText = ""
            kanjiImage = nil
        }
    }
}

#elseif os(iOS)
struct MacAddWordView: View {
    var body: some View {
        EmptyView()
    }
}


struct MacAddWordView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddWordView()
    }
}
#endif

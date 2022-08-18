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
    private enum EditFocus: Hashable {
        case meaning, gana, kanji
    }
    
    // MARK: Properties
    @StateObject private var viewModel = ViewModel()
    @FocusState private var editFocus: EditFocus?
    
    // MARK: Body
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    if viewModel.didBooksFetched && !viewModel.bookList.isEmpty {
                        Picker(selection: $viewModel.selectedBookIndex, label: Text("선택된 단어장:")) {
                            ForEach(0..<viewModel.bookList.count, id: \.self) { index in
                                Text(viewModel.bookList[index].title)
                            }
                        }
                        .padding()
                    }
                }
                VStack {
                    Text("뜻 입력")
                        .font(.system(size: 20))
                    TextEditor(text: $viewModel.meaningText)
                        .font(.system(size: 30))
                        .frame(height: Constants.Size.deviceHeight / 8)
                        .padding(.horizontal)
                    Button {
                        viewModel.checkIfOverlap()
                    } label: {
                        Text(viewModel.overlapCheckButtonTitle)
                    }
                    .disabled(viewModel.isOverlapped != nil || viewModel.isCheckingOverlap)
                    if let frontImage = viewModel.meaningImage {
                        Image(nsImage: frontImage)
                            .resizable()
                            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                            .onTapGesture { viewModel.meaningImage = nil }
                    } else {
                        Button {
                            viewModel.meaningImage = getImageFromPasteBoard()
                        } label: {
                            Text("뜻 이미지")
                        }
                    }
                }
                .padding(.bottom)
                VStack {
                    Text("가나 입력")
                        .font(.system(size: 20))
                    TextEditor(text: $viewModel.ganaText)
                        .font(.system(size: 30))
                        .frame(height: Constants.Size.deviceHeight / 8)
                        .padding(.horizontal)
                        .focused($editFocus, equals: .gana)
                    if let backImage = viewModel.ganaImage {
                        Image(nsImage: backImage)
                            .resizable()
                            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                            .onTapGesture { viewModel.ganaImage = nil }
                    } else {
                        Button {
                            viewModel.ganaImage = getImageFromPasteBoard()
                        } label: {
                            Text("가나 이미지")
                        }
                    }
                }
                VStack {
                    Text("한자 입력")
                        .font(.system(size: 20))
                    TextEditor(text: $viewModel.kanjiText)
                        .font(.system(size: 30))
                        .frame(height: Constants.Size.deviceHeight / 8)
                        .padding(.horizontal)
                        .focused($editFocus, equals: .kanji)
                    if let backImage = viewModel.kanjiImage {
                        Image(nsImage: backImage)
                            .resizable()
                            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                            .onTapGesture { viewModel.kanjiImage = nil }
                    } else {
                        Button {
                            viewModel.kanjiImage = getImageFromPasteBoard()
                        } label: {
                            Text("한자 이미지")
                        }
                    }
                }
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
    
    // TODO: 클립보드에서 복사해오는 법 (비지니스 로직인가 뷰인가)
    func getImageFromPasteBoard() -> NSImage? {
        let pb = NSPasteboard.general
        let type = NSPasteboard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
        return NSImage(data: imgData)
    }
}

// MARK: SubViews
extension MacAddWordView {
    
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
        @Published var meaningImage: NSImage?
        @Published var ganaText: String = ""
        @Published var ganaImage: NSImage?
        @Published var kanjiText: String = ""
        @Published var kanjiImage: NSImage?
        
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

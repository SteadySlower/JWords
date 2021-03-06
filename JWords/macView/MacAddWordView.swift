//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

#if os(macOS)
struct MacAddWordView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            VStack {
                if viewModel.didBooksFetched && !viewModel.bookList.isEmpty {
                    // TODO: Picker는 Hashable을 필요로 함 + selection에 Int아니고 실제 type을 넣으니까 안됨
                    Picker(selection: $viewModel.selectedBookIndex, label: Text("선택된 단어장: \(viewModel.bookList[viewModel.selectedBookIndex].title)")) {
                        ForEach(0..<viewModel.bookList.count, id: \.self) { index in
                            Text(viewModel.bookList[index].title)
                        }
                    }
                    .padding()
                }
            }
            VStack {
                Text("앞면 입력")
                    .font(.system(size: 20))
                TextEditor(text: $viewModel.frontText)
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
                Button {
                    viewModel.checkIfOverlap()
                } label: {
                    Text(viewModel.overlapCheckButtonTitle)
                }
                .disabled(viewModel.isOverlapped != nil || viewModel.isCheckingOverlap)
                if let frontImage = viewModel.frontImage {
                    Image(nsImage: frontImage)
                        .resizable()
                        .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                        .onTapGesture { viewModel.frontImage = nil }
                } else {
                    Button {
                        viewModel.frontImage = getImageFromPasteBoard()
                    } label: {
                        Text("앞면 이미지")
                    }
                }
            }
            .padding(.bottom)
            VStack {
                Text("뒷면 입력")
                    .font(.system(size: 20))
                TextEditor(text: $viewModel.backText)
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
                if let backImage = viewModel.backImage {
                    Image(nsImage: backImage)
                        .resizable()
                        .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                        .onTapGesture { viewModel.backImage = nil }
                } else {
                    Button {
                        viewModel.backImage = getImageFromPasteBoard()
                    } label: {
                        Text("뒷면 이미지")
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
        .onAppear { viewModel.getWordBooks() }
    }
    
    // TODO: 클립보드에서 복사해오는 법 (비지니스 로직인가 뷰인가)
    func getImageFromPasteBoard() -> NSImage? {
        let pb = NSPasteboard.general
        let type = NSPasteboard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
       
        return NSImage(data: imgData)
    }
}

extension MacAddWordView {
    final class ViewModel: ObservableObject {
        @Published var frontText: String = "" {
            didSet {
                isOverlapped = nil
            }
        }
        @Published var frontImage: NSImage?
        @Published var backText: String = ""
        @Published var backImage: NSImage?
        @Published var bookList: [WordBook] = []
        @Published var selectedBookIndex = 0
        @Published var didBooksFetched: Bool = false
        @Published var isUploading: Bool = false
        
        var isSaveButtonUnable: Bool {
            return (frontText.isEmpty && frontImage == nil) || (backText.isEmpty && backImage == nil) || isUploading
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
            let wordInput = WordInput(frontText: frontText, frontImage: frontImage, backText: backText, backImage: backImage)
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
            WordService.checkIfOverlap(wordBookID: selectedBookID, frontText: frontText) { [weak self] isOverlapped, error in
                if let error = error { print("디버그: \(error)"); return }
                self?.isOverlapped = isOverlapped ?? false
                self?.isCheckingOverlap = false
            }
        }
        
        private func clearInputs() {
            frontText = ""
            frontImage = nil
            backText = ""
            backImage = nil
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

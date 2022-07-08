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
                Text("앞면 입력")
                TextField("앞면 텍스트", text: $viewModel.frontText)
                    .padding()
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
            VStack {
                Text("뒷면 입력")
                TextField("뒷면 텍스트", text: $viewModel.backText)
                    .padding()
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
    
    // TODO: 클립보드에서 복사해오는 법
    func getImageFromPasteBoard() -> NSImage? {
        let pb = NSPasteboard.general
        let type = NSPasteboard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
       
        return NSImage(data: imgData)
    }
}

extension MacAddWordView {
    final class ViewModel: ObservableObject {
        @Published var frontText: String = ""
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

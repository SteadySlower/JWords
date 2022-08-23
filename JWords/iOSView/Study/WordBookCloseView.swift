//
//  WordBookCloseView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI

struct WordBookCloseView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showProgressView = false
    @Binding private var didClosed: Bool
    
    init(wordBook: WordBook, toMoveWords: [Word], didClosed: Binding<Bool>) {
        self.viewModel = ViewModel(toClose: wordBook, toMoveWords: toMoveWords)
        self._didClosed = didClosed
        // FIXME: 이 API 호출은 3번 실행됨. (Modal이 3번 init되기 때문)
        viewModel.getWordBooks()
    }
    
    var body: some View {
        ZStack {
            if showProgressView {
                ProgressView()
            }
            VStack {
                Text("\(viewModel.toMoveWords.count)개의 틀린 단어들을 이동할 단어장을 골라주세요.")
                Picker("이동할 단어장 고르기", selection: $viewModel.selectedID) {
                    Text(viewModel.wordBooks.isEmpty ? "로딩중" : "이동 안함")
                        .tag(nil as String?)
                    ForEach(viewModel.wordBooks) {
                        Text($0.title)
                            .tag($0.id as String?)
                    }
                }
                #if os(iOS)
                .pickerStyle(.wheel)
                #endif
                HStack {
                    Button("취소") {
                        didClosed = false
                        dismiss()
                    }
                    Button(viewModel.selectedID != nil ? "이동" : "닫기") {
                        showProgressView = true
                        viewModel.closeBook {
                            didClosed = true
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
}

extension WordBookCloseView {
    final class ViewModel: ObservableObject {
        private let toClose: WordBook
        let toMoveWords: [Word]
        
        @Published var wordBooks = [WordBook]()
        @Published var selectedID: String?
        
        init(toClose: WordBook, toMoveWords: [Word]) {
            self.toClose = toClose
            self.toMoveWords = toMoveWords
        }
        
        func getWordBooks() {
            WordService.getWordBooks { [weak self] books, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let books = books else {
                    print("Debug: No wordbook Found")
                    return
                }
                
                self?.wordBooks = books
            }
        }
        
        func closeBook(completionHandler: @escaping () -> Void) {
            guard let id = toClose.id else { return }
            WordService.closeWordBook(of: id, to: selectedID, toMoveWords: toMoveWords) { error in
                if let error = error { print(error) }
                completionHandler()
            }
        }
    }
}

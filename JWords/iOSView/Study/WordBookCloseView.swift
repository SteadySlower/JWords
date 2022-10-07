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
    @Binding private var didClosed: Bool
    
    init(wordBook: WordBook, toMoveWords: [Word], didClosed: Binding<Bool>, dependency: Dependency) {
        self.viewModel = ViewModel(toClose: wordBook, toMoveWords: toMoveWords, dependency: dependency)
        self._didClosed = didClosed
        // FIXME: 이 API 호출은 3번 실행됨. (Modal이 3번 init되기 때문)
        viewModel.getWordBooks()
    }
    
    var body: some View {
        ZStack {
            if viewModel.isClosing {
                ProgressView()
            }
            VStack {
                Text("\(viewModel.toMoveWords.count)개의 틀린 단어들을 이동할 단어장을 골라주세요.")
                Picker("이동할 단어장 고르기", selection: $viewModel.selectedID) {
                    Text(viewModel.wordBooks.isEmpty ? "로딩중" : "이동 안함")
                        .tag(nil as String?)
                    ForEach(viewModel.wordBooks, id: \.id) {
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
                        viewModel.closeBook {
                            didClosed = true
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isClosing)
                }
            }
        }
    }
    
}

extension WordBookCloseView {
    final class ViewModel: ObservableObject {
        private let toClose: WordBook
        let toMoveWords: [Word]
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        @Published var wordBooks = [WordBook]()
        @Published var selectedID: String?
        @Published var isClosing: Bool = false
        
        var selectedWordBook: WordBook? {
            if let selectedID = selectedID {
                return wordBooks.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
        
        init(toClose: WordBook, toMoveWords: [Word], dependency: Dependency) {
            self.toClose = toClose
            self.toMoveWords = toMoveWords
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
        }
        
        func getWordBooks() {
            wordBookService.getWordBooks { [weak self] books, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let books = books else {
                    print("Debug: No wordbook Found")
                    return
                }
                
                self?.wordBooks = books.filter { $0.closed != true && $0.id != self?.toClose.id }
            }
        }
        
        func closeBook(completionHandler: @escaping () -> Void) {
            todayService.updateReviewed(toClose.id)
            isClosing = true
            wordBookService.moveWords(of: toClose, to: selectedWordBook, toMove: toMoveWords) { error in
                // TODO: Handle Error
                if let error = error {
                    print(error)
                }
                completionHandler()
            }
        }
    }
}

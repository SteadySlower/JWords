//
//  WordMoveView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI

struct WordMoveView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding private var didClosed: Bool
    
    init(wordBook: WordBook, toMoveWords: [Word], didClosed: Binding<Bool>, dependency: Dependency) {
        self.viewModel = ViewModel(fromBook: wordBook, toMoveWords: toMoveWords, dependency: dependency)
        self._didClosed = didClosed
        // FIXME: 이 API 호출은 3번 실행됨. (Modal이 3번 init되기 때문)
        viewModel.getWordBooks()
    }
    
    var body: some View {
        ZStack {
            if viewModel.isClosing {
                ProgressView()
                    .scaleEffect(5)
            }
            VStack {
                Text("\(viewModel.toMoveWords.count)개의 단어들을 이동할 단어장을 골라주세요.")
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
                Toggle("단어장 마감하기", isOn: $viewModel.willCloseBook)
                    .padding(.horizontal, 20)
                HStack {
                    Button("취소") {
                        didClosed = false
                        dismiss()
                    }
                    Button(viewModel.selectedID != nil ? "이동" : "닫기") {
                        viewModel.moveWords {
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

extension WordMoveView {
    final class ViewModel: ObservableObject {
        private let fromBook: WordBook
        let toMoveWords: [Word]
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        @Published var wordBooks = [WordBook]()
        @Published var selectedID: String?
        @Published var isClosing: Bool = false
        @Published var willCloseBook: Bool = false
        
        var selectedWordBook: WordBook? {
            if let selectedID = selectedID {
                return wordBooks.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
        
        init(fromBook: WordBook, toMoveWords: [Word], dependency: Dependency) {
            self.fromBook = fromBook
            self.toMoveWords = toMoveWords
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
            
            // 오늘 마지막 복습 일정인 book은 toggle 체크되어 있도록
            if fromBook.dayFromToday == 28 {
                self.willCloseBook = true
            }
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
                
                self?.wordBooks = books.filter { $0.id != self?.fromBook.id }
            }
        }
        
        // TODO: Handle Error
        func moveWords(completionHandler: @escaping () -> Void) {
            isClosing = true
            
            let group = DispatchGroup()
            
            group.enter()
            todayService.updateReviewed(fromBook.id) { error in
                if let error = error {
                    print(error)
                    return
                }
                group.leave()
            }
            
            group.enter()
            wordBookService.moveWords(of: fromBook, to: selectedWordBook, toMove: toMoveWords) { error in
                if let error = error {
                    print(error)
                    return
                }
                group.leave()
            }
            
            if willCloseBook {
                group.enter()
                wordBookService.closeWordBook(fromBook) { error in
                    if let error = error {
                        print(error)
                        return
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completionHandler()
            }
        }
    }
}

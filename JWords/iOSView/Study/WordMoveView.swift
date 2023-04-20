//
//  WordMoveView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI
import ComposableArchitecture

struct MoveWords: ReducerProtocol {
    struct State: Equatable {
        let fromBook: WordBook
        let toMoveWords: [Word]
        var wordBooks = [WordBook]()
        var selectedID: String?
        var isLoading: Bool = false
        var willCloseBook: Bool = false
        
        init(fromBook: WordBook,
             toMoveWords: [Word],
             wordBooks: [WordBook] = [WordBook](),
             selectedID: String? = nil,
             isLoading: Bool,
             willCloseBook: Bool) {
            self.fromBook = fromBook
            self.toMoveWords = toMoveWords
            self.wordBooks = wordBooks
            self.selectedID = selectedID
            self.isLoading = isLoading
            self.willCloseBook = willCloseBook
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case wordBookResponse(TaskResult<[WordBook]>)
        case updateSelection(String?)
        case updateWillCloseBook(willClose: Bool)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            default:
                return .none
            }
        }
    }
}

struct WordMoveView: View {
    let store: StoreOf<MoveWords>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                if vs.isLoading {
                    ProgressView()
                        .scaleEffect(5)
                }
                VStack {
                    Text("\(vs.toMoveWords.count)개의 단어들을 이동할 단어장을 골라주세요.")
                    Picker("이동할 단어장 고르기", selection: vs.binding(
                        get: \.selectedID,
                        send: MoveWords.Action.updateSelection)
                    ) {
                        Text(vs.wordBooks.isEmpty ? "로딩중" : "이동 안함")
                            .tag(nil as String?)
                        ForEach(vs.wordBooks, id: \.id) {
                            Text($0.title)
                                .tag($0.id as String?)
                        }
                    }
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #endif
                    Toggle("단어장 마감하기", isOn: vs.binding(
                        get: \.willCloseBook,
                        send: MoveWords.Action.updateWillCloseBook(willClose:))
                    )
                    .padding(.horizontal, 20)
                    HStack {
                        Button("취소") {
                            
                        }
                        Button(vs.selectedID != nil ? "이동" : "닫기") {
                        }
                        .disabled(vs.isLoading)
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
    
}

struct WordMoveView_Previews: PreviewProvider {
    static var previews: some View {
        WordMoveView(
            store: Store(
                initialState: MoveWords.State(fromBook: WordBook(title: "타이틀"),
                                              toMoveWords: [],
                                              isLoading: false,
                                              willCloseBook: true),
                reducer: MoveWords()._printChanges()
            )
        )
    }
}


// MARK: ViewModel

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
        
        init(fromBook: WordBook, toMoveWords: [Word], dependency: ServiceManager) {
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

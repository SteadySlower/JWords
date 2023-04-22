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
        var isLoading: Bool
        var willCloseBook: Bool
        
        init(fromBook: WordBook,
             toMoveWords: [Word],
             wordBooks: [WordBook] = [WordBook](),
             selectedID: String? = nil,
             isLoading: Bool = false) {
            self.fromBook = fromBook
            self.toMoveWords = toMoveWords
            self.wordBooks = wordBooks
            self.selectedID = selectedID
            self.isLoading = isLoading
            self.willCloseBook = fromBook.dayFromToday >= 28 ? true : false
        }
        
        var selectedWordBook: WordBook? {
            if let selectedID = selectedID {
                return wordBooks.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case wordBookResponse(TaskResult<[WordBook]>)
        case updateSelection(String?)
        case updateWillCloseBook(willClose: Bool)
        case closeButtonTapped
        case moveWordsResponse(TaskResult<Void>)
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear):
                return true
            case let (.wordBookResponse(lhsResult), .wordBookResponse(rhsResult)):
                return lhsResult == rhsResult
            case let (.updateSelection(lhsSelection), .updateSelection(rhsSelection)):
                return lhsSelection == rhsSelection
            case let (.updateWillCloseBook(lhsWillClose), .updateWillCloseBook(rhsWillClose)):
                return lhsWillClose == rhsWillClose
            case (.closeButtonTapped, .closeButtonTapped):
                return true
            case (.moveWordsResponse, .moveWordsResponse):
                return true
            default:
                return false
            }
        }
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.todayClient) var todayClient
    private enum FetchWordBooksID {}
    private enum MoveWordsID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .task {
                    await .wordBookResponse(TaskResult { try await wordBookClient.wordBooks() })
                }
                .cancellable(id: FetchWordBooksID.self)
            case let .wordBookResponse(.success(wordBooks)):
                state.wordBooks = wordBooks
                state.isLoading = false
                return .none
            case .wordBookResponse(.failure):
                state.wordBooks = []
                state.isLoading = false
                return .none
            case .updateSelection(let id):
                state.selectedID = id
                return .none
            case .updateWillCloseBook(let willClose):
                state.willCloseBook = willClose
                return .none
            case .closeButtonTapped:
                state.isLoading = true
                let toBook = state.selectedWordBook
                let toMoveWords = state.toMoveWords
                let fromBook = state.fromBook
                let willCloseBook = state.willCloseBook
                return .task {
                    await .moveWordsResponse(TaskResult {
                        try await withThrowingTaskGroup(of: Void.self) { group in
                            group.addTask { try await todayClient.updateReviewed(fromBook.id) }
                            group.addTask { try await wordBookClient.moveWords(fromBook, toBook, toMoveWords) }
                            if willCloseBook {
                                group.addTask { try await wordBookClient.closeBook(fromBook) }
                            }
                            try await group.next()
                        }
                    })
                }.cancellable(id: MoveWordsID.self)
            case .moveWordsResponse(.success):
                state.isLoading = false
                return .none
            case let .moveWordsResponse(.failure(error)):
                state.isLoading = false
                print("디버그: \(error)")
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
                            vs.send(.closeButtonTapped)
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
                                              isLoading: false),
                reducer: MoveWords()._printChanges()
            )
        )
    }
}

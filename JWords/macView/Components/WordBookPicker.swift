//
//  WordBookPicker.swift
//  JWords
//
//  Created by JW Moon on 2023/04/29.
//

import SwiftUI
import ComposableArchitecture

struct SelectWordBook: ReducerProtocol {
    
    struct State: Equatable {
        var wordBooks = [WordBook]()
        var selectedID: String? = nil
        var wordCount: Int? = nil
        var didFetched = false
        
        var selectedBook: WordBook? {
            wordBooks.first(where: { $0.id == selectedID })
        }
        
        var pickerDefaultText: String {
            if didFetched && !wordBooks.isEmpty {
                return "단어장을 선택해주세요"
            } else if didFetched && wordBooks.isEmpty {
                return "단어장 리스트 불러오기 실패"
            } else {
                return "단어장 불러오는 중..."
            }
        }
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    private enum fetchBooksID {}
    private enum fetchWordCountID {}
    
    enum Action: Equatable {
        case onAppear
        case booksResponse(TaskResult<[WordBook]>)
        case updateID(String?)
        case wordCountResponse(TaskResult<Int>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task {
                    await .booksResponse(TaskResult { try await wordBookClient.wordBooks() })
                }
            case let .booksResponse(.success(books)):
                state.didFetched = true
                state.wordBooks = books
                return .none
            case .updateID(let id):
                state.selectedID = id
                state.wordCount = nil
                guard let book = state.selectedBook else { return .none }
                return .task {
                    await .wordCountResponse(TaskResult { try await wordBookClient.wordCount(book) })
                }
            case let .wordCountResponse(.success(count)):
                state.wordCount = count
                return .none
            default:
                return .none
            }
        }
    }
}

struct WordBookPicker: View {
    
    let store: StoreOf<SelectWordBook>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            HStack {
                Picker("", selection:
                        vs.binding(
                             get: \.selectedID,
                             send: SelectWordBook.Action.updateID)
                ) {
                    Text(vs.pickerDefaultText)
                        .tag(nil as String?)
                    ForEach(vs.wordBooks, id: \.id) { book in
                        Text(book.title)
                            .tag(book.id as String?)
                    }
                }
                Group {
                    if let wordCount = vs.wordCount {
                        Text("단어 수: \(wordCount)개")
                    } else {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                }
                .frame(height: 50)
                .opacity(vs.selectedID == nil ? 0 : 1)
            }
            .padding()
            .onAppear { vs.send(.onAppear) }
        }
    }
}

struct WordBookPicker_Previews: PreviewProvider {
    static var previews: some View {
        WordBookPicker(
            store: Store(
                initialState: SelectWordBook.State(),
                reducer: SelectWordBook()._printChanges()
            )
        )
    }
}

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
        let pickerName: String
        
        var convertTable = [String:Bool]()
        
        init(pickerName: String = "") {
            self.pickerName = pickerName
        }
        
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
        
        mutating func onWordAdded() {
            if let wordCount = wordCount {
                self.wordCount = wordCount + 1
            }
        }
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    private enum fetchBooksID {}
    private enum fetchWordCountID {}
    
    private let cd = CoreDataClient.shared
    
    enum Action: Equatable {
        case onAppear
        case booksResponse(TaskResult<[WordBook]>)
        case updateID(String?)
        case bookUpdated
        case wordCountResponse(TaskResult<Int>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task {
                    await .booksResponse(TaskResult { try await wordBookClient.wordBooks() })
                }
                .cancellable(id: fetchBooksID.self)
            case let .booksResponse(.success(books)):
                state.didFetched = true
                state.wordBooks = books
                for book in books {
                    state.convertTable[book.id] = try! cd.checkIfExist(book: book)
                }
                return .none
            case .updateID(let id):
                state.selectedID = id
                state.wordCount = nil
                guard let book = state.selectedBook else { return .task { .bookUpdated } }
                return .task {
                    await .wordCountResponse(TaskResult { try await wordBookClient.wordCount(book) })
                }
                .cancellable(id: fetchWordCountID.self)
            case let .wordCountResponse(.success(count)):
                state.wordCount = count
                return .task { .bookUpdated }
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
                Picker(vs.pickerName, selection:
                        vs.binding(
                             get: \.selectedID,
                             send: SelectWordBook.Action.updateID)
                ) {
                    Text(vs.pickerDefaultText)
                        .tag(nil as String?)
                    ForEach(vs.wordBooks, id: \.id) { book in
                        Text(book.title + "\(vs.convertTable[book.id, default: false] ? " (이미 이동)" : "")")
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

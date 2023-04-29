//
//  MacAddBookView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture

struct AddBook: ReducerProtocol {
    struct State: Equatable {
        var bookName: String = ""
        var preferredFrontType: FrontType = .kanji
        var isLoading: Bool = false
        
        var disableButton: Bool {
            bookName.isEmpty || isLoading
        }
        
        mutating func clear() {
            bookName = ""
            preferredFrontType = .kanji
        }
        
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    
    enum Action: Equatable {
        case updateName(String)
        case updateFrontType(FrontType)
        case saveButtonTapped
        case addBookResponse(TaskResult<Bool>)
    }
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateName(let text):
                state.bookName = text
                return .none
            case .updateFrontType(let type):
                state.preferredFrontType = type
                return .none
            case .saveButtonTapped:
                state.isLoading = true
                return .task { [title = state.bookName, type = state.preferredFrontType] in
                    await .addBookResponse(TaskResult { try await wordBookClient.addBook(title, type) })
                }
            case .addBookResponse(.success):
                state.isLoading = false
                state.clear()
                return .none
            default:
                return .none
            }
        }
    }

}


struct MacAddBookView: View {
    
    let store: StoreOf<AddBook>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                TextField("단어장 이름",
                          text: vs.binding(
                            get: \.bookName,
                            send: AddBook.Action.updateName)
                )
                .padding()
                Picker("",
                       selection: vs.binding(
                        get: \.preferredFrontType,
                        send: AddBook.Action.updateFrontType)
                ) {
                    ForEach(FrontType.allCases, id: \.self) {
                        Text($0.preferredTypeText)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                Button {
                    vs.send(.saveButtonTapped)
                } label: {
                    Text("저장")
                }
                .disabled(vs.disableButton)
            }
        }
    }
}

struct MacAddBookView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddBookView(
            store: Store(
                initialState: AddBook.State(),
                reducer: AddBook()._printChanges()
            )
        )
    }
}

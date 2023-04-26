//
//  BookInputView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/26.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct InputBook: ReducerProtocol {
    
    struct State: Equatable {
        var title: String = ""
        var preferredFrontType: FrontType = .kanji
        var isLoading: Bool = false
        
        mutating func clear() {
            title = ""
            preferredFrontType = .kanji
        }
    }
    
    enum Action: Equatable {
        case updateTitle(String)
        case updatePreferredFrontType(FrontType)
        case addButtonTapped
        case cancelButtonTapped
        case addBookResponse(TaskResult<Void>)
        
        static func == (lhs: InputBook.Action, rhs: InputBook.Action) -> Bool {
            switch (lhs, rhs) {
            case let (.updateTitle(lhsTitle), .updateTitle(rhsTitle)):
                return lhsTitle == rhsTitle
            case let (.updatePreferredFrontType(lhsType), .updatePreferredFrontType(rhsType)):
                return lhsType == rhsType
            case (.addButtonTapped, .addButtonTapped):
                return true
            case (.cancelButtonTapped, .cancelButtonTapped):
                return true
            case (.addBookResponse, .addBookResponse):
                return true
            default:
                return false
            }
        }
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    private enum AddBookID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .updateTitle(text):
                state.title = text
                return .none
            case let .updatePreferredFrontType(type):
                state.preferredFrontType = type
                return .none
            case .addButtonTapped:
                let title = state.title
                let type = state.preferredFrontType
                guard !title.isEmpty else { return .none }
                state.isLoading = true
                return .task {
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

struct WordBookAddModal: View {
    let store: StoreOf<InputBook>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                TextField("단어장 이름", text: vs.binding(get: \.title, send: InputBook.Action.updateTitle))
                    .padding()
                Picker("", selection: vs.binding(get: \.preferredFrontType, send: InputBook.Action.updatePreferredFrontType)) {
                    ForEach(FrontType.allCases, id: \.self) {
                        Text($0.preferredTypeText)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                HStack {
                    Button("추가"){
                        vs.send(.addButtonTapped)
                    }
                    Button("취소", role: .cancel) {
                        vs.send(.cancelButtonTapped)
                    }
                }
            }
            .loadingView(vs.isLoading)
            .padding()
        }
    }
}

struct WordBookAddModal_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WordBookAddModal(
                store: Store(
                    initialState: InputBook.State(),
                    reducer: InputBook()._printChanges()
                )
            )
        }
    }
}

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
        let set: StudySet?
        var title: String
        var preferredFrontType: FrontType
        var isLoading: Bool = false
        var alert: AlertState<Action>?
        
        init(set: StudySet? = nil) {
            self.set = set
            self.title = set?.title ?? ""
            self.preferredFrontType = set?.preferredFrontType ?? .kanji
        }
        
        mutating func clear() {
            title = ""
            preferredFrontType = .kanji
        }
    }
    
    enum Action: Equatable {
        case updateTitle(String)
        case updatePreferredFrontType(FrontType)
        case showErrorAlert(AppError)
        case alertDismissed
        case addButtonTapped
        case cancelButtonTapped
        case setAdded
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .updateTitle(text):
                state.title = text
                return .none
            case let .updatePreferredFrontType(type):
                state.preferredFrontType = type
                return .none
            case .showErrorAlert(let error):
                state.alert = error.simpleAlert(action: Action.self)
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case .addButtonTapped:
                guard !state.title.isEmpty else {
                    return .task { .showErrorAlert(.emptyTitle) }
                }
                state.isLoading = true
                try! cd.insertSet(title: state.title, preferredFrontType: state.preferredFrontType)
                state.isLoading = false
                return .task { .setAdded }
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
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
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

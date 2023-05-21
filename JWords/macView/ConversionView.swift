//
//  MacStudyView.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct ConversionList: ReducerProtocol {
    struct State: Equatable {
        var coredataSet = SelectStudySet.State(pickerName: "CoreData 단어장")
        var firebaseBook = SelectWordBook.State(pickerName: "Firebase 단어장")
    }
    
    enum Action: Equatable {
        case selectStudySet(action: SelectStudySet.Action)
        case selectWordBook(action: SelectWordBook.Action)
    }
    
    private let cd = CoreDataClient.shared
    @Dependency(\.wordBookClient) var wordBookClient
    private enum fetchBooksID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                break
            }
            return .none
        }
        Scope(state: \.coredataSet, action: /Action.selectStudySet(action:)) {
            SelectStudySet()
        }
        Scope(state: \.firebaseBook, action: /Action.selectWordBook(action:)) {
            SelectWordBook()
        }
    }
    
}

struct ConversionView: View {
    
    let store: StoreOf<ConversionList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                HStack {
                    StudySetPicker(store: store.scope(
                        state: \.coredataSet,
                        action: ConversionList.Action.selectStudySet(action:))
                    )
                    WordBookPicker(store: store.scope(
                        state: \.firebaseBook,
                        action: ConversionList.Action.selectWordBook(action:))
                    )
                }
            }
        }
    }
}

struct MacStudyView_Previews: PreviewProvider {
    static var previews: some View {
        ConversionView(
            store: Store(
                initialState: ConversionList.State(),
                reducer: ConversionList()._printChanges()
            )
        )
    }
}

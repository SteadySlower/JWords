//
//  DeleteList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct DeleteWords: ReducerProtocol {
    struct State: Equatable {
        var words: IdentifiedArrayOf<DeleteWord.State>
        
        init(words: [StudyUnit], frontType: FrontType) {
            self.words = IdentifiedArray(uniqueElements: words.map { DeleteWord.State(unit: $0, frontType: frontType) })
        }
        
    }
    
    enum Action: Equatable {
        case word(id: DeleteWord.State.ID, action: DeleteWord.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.words, action: /Action.word(id:action:)) {
            DeleteWord()
        }
    }
}

struct DeleteList: View {
    
    let store: StoreOf<DeleteWords>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(
              self.store.scope(state: \.words, action: DeleteWords.Action.word(id:action:))
            ) {
                DeleteCell(store: $0)
            }
        }
    }
    
}

#Preview {
    DeleteList(store: Store(
        initialState: DeleteWords.State(words: .mock, frontType: .kanji),
        reducer: DeleteWords())
    )
}

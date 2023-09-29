//
//  EditList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct EditWords: ReducerProtocol {
    struct State: Equatable {
        var words: IdentifiedArrayOf<EditWord.State>
        
        init(words: [StudyUnit], frontType: FrontType) {
            self.words = IdentifiedArray(uniqueElements: words.map { EditWord.State(unit: $0, frontType: frontType) })
        }
        
    }
    
    enum Action: Equatable {
        case word(id: EditWord.State.ID, action: EditWord.Action)
        case toEditUnitSelected(StudyUnit)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .word(_, let action):
                switch action {
                case .cellTapped(let unit):
                    return .task { .toEditUnitSelected(unit) }
                }
            default: return .none
            }
        }
        .forEach(\.words, action: /Action.word(id:action:)) {
            EditWord()
        }
    }
}

struct EditList: View {
    
    let store: StoreOf<EditWords>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(
              self.store.scope(state: \.words, action: EditWords.Action.word(id:action:))
            ) {
                EditCell(store: $0)
            }
        }
    }
    
}

#Preview {
    EditList(store: Store(
        initialState: EditWords.State(words: .mock, frontType: .kanji),
        reducer: EditWords())
    )
}

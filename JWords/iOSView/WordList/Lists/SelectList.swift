//
//  SelectList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct SelectWords: ReducerProtocol {
    struct State: Equatable {
        var words: IdentifiedArrayOf<SelectionWord.State>
        
        init(words: [StudyUnit], frontType: FrontType) {
            self.words = IdentifiedArray(uniqueElements: words.map { SelectionWord.State(unit: $0, frontType: frontType) })
        }
        
    }
    
    enum Action: Equatable {
        case word(id: SelectionWord.State.ID, action: SelectionWord.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.words, action: /Action.word(id:action:)) {
            SelectionWord()
        }
    }
}

struct SelectList: View {
    
    let store: StoreOf<SelectWords>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(
              self.store.scope(state: \.words, action: SelectWords.Action.word(id:action:))
            ) {
                SelectionCell(store: $0)
            }
        }
    }
    
}

#Preview {
    SelectList(store: Store(
        initialState: SelectWords.State(words: .mock, frontType: .kanji),
        reducer: SelectWords())
    )
}


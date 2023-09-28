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

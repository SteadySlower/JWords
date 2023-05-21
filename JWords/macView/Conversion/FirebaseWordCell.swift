//
//  FirebaseWordList.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct FirebaseWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        let word: Word
        
        init(word: Word) {
            self.id = word.id
            self.word = word
        }
    }
    
    struct Action: Equatable {
        
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

struct FirebaseWordCell: View {
    
    let store: StoreOf<FirebaseWord>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            Text(vs.word.kanjiText)
        }
    }
}

struct FirebaseWordList_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseWordCell(
            store: Store(
                initialState: FirebaseWord.State(word: .init(index: 0)) ,
                reducer: FirebaseWord()._printChanges()
            )
        )
    }
}

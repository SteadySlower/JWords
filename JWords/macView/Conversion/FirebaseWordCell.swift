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
        var huriText: EditHuriganaText.State
        
        init(word: Word) {
            self.id = word.id
            self.word = word
            self.huriText = .init(hurigana: HuriganaConverter.shared.convert(word.kanjiText))
        }
    }
    
    enum Action: Equatable {
        case editHuriText(action: EditHuriganaText.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.huriText, action: /Action.editHuriText(action:)) {
            EditHuriganaText()
        }
    }
}

struct FirebaseWordCell: View {
    
    let store: StoreOf<FirebaseWord>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text(vs.word.kanjiText)
                EditableHuriganaText(store: store.scope(
                    state: \.huriText,
                    action: FirebaseWord.Action.editHuriText(action:))
                )
            }
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

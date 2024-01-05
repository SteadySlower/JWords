//
//  EditKanji.swift
//  JWords
//
//  Created by Jong Won Moon on 11/22/23.
//

import SwiftUI
import ComposableArchitecture

struct EditKanji: Reducer {
    struct State: Equatable {
        let kanji: Kanji
        var input: InputKanji.State
        
        init(_ kanji: Kanji) {
            self.kanji = kanji
            self.input = .init(
                kanji: kanji.kanjiText,
                meaning: kanji.meaningText,
                ondoku: kanji.ondoku,
                kundoku: kanji.kundoku,
                isKanjiEditable: false
            )
        }
    }
    
    enum Action: Equatable {
        case input(InputKanji.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .input(let action):
                switch action {
                case .updateKanji:
                    state.input.kanji = state.kanji.kanjiText
                    return .none
                default:
                    return .none
                }
            default: return .none
            }
        }
        Scope(
            state: \.input,
            action: /Action.input,
            child: { InputKanji() }
        )
    }
    
}

struct EditKanjiView: View {
    
    let store: StoreOf<EditKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            KanjiInputView(
                store: store.scope(
                    state: \.input,
                    action: EditKanji.Action.input)
            )
        }
    }
}

#Preview {
    EditKanjiView(
        store: Store(
            initialState: EditKanji.State(
                .init(
                    kanjiText: "一",
                    meaningText: "한 일",
                    ondoku: "いち",
                    kundoku: "い",
                    createdAt: .now,
                    usedIn: 1
                )
            ),
            reducer: { EditKanji()._printChanges() }
        )
    )
}

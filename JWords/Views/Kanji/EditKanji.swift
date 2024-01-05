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
        case edit
        case edited(Kanji)
        case cancel
    }
    
    @Dependency(\.kanjiClient) var kanjiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .edit:
                let input = StudyKanjiInput(
                    kanjiText: state.input.kanji,
                    meaningText: state.input.meaning,
                    ondoku: state.input.ondoku,
                    kundoku: state.input.kundoku)
                let edited = try! kanjiClient.edit(state.kanji, input)
                return .send(.edited(edited))
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
            VStack(spacing: 40) {
                KanjiInputView(
                    store: store.scope(
                        state: \.input,
                        action: EditKanji.Action.input)
                )
                HStack(spacing: 100) {
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle())
                    Button("수정") {
                        vs.send(.edit)
                    }
                    .buttonStyle(InputButtonStyle())
                }
            }
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

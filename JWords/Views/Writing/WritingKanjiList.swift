//
//  WrtingKanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import ComposableArchitecture

struct WritingKanjiList: Reducer {
    struct State: Equatable {
        var kanjis: IdentifiedArrayOf<DisplayWritingKanji.State>
        
        func findKanjiByID(id: DisplayWritingKanji.State.ID) -> Kanji? {
            kanjis.filter { $0.id == id }.first?.kanji
        }
    }
    
    enum Action: Equatable {
        case fetchKanjis
        case kanjiSelected(Kanji?)
        case kanji(DisplayWritingKanji.State.ID, DisplayWritingKanji.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchKanjis:
                return .none
            case .kanji(let id, let action):
                switch action {
                case .select:
                    let selected = state.findKanjiByID(id: id)
                    return .send(.kanjiSelected(selected))
                default:
                    return .none
                }
            default: return .none
            }
        }
        .forEach(
            \.kanjis,
             action: /Action.kanji,
             element: { DisplayWritingKanji() }
        )
    }
}

struct WritingKanjiListView: View {
    
    let store: StoreOf<WritingKanjiList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                LazyVStack {
                    ForEachStore(store.scope(
                        state: \.kanjis,
                        action: WritingKanjiList.Action.kanji)
                    ) {
                        WritingKanjiCell(store: $0)
                    }
                }
            }
        }
    }
}


#Preview {
    WritingKanjiListView(
        store: Store(
            initialState: WritingKanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: [Kanji].mock.map { DisplayWritingKanji.State(kanji: $0) }
                )
            ),
            reducer: { WritingKanjiList() }
        )
    )
}

//
//  WrtingKanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WritingKanjiList {
    @ObservableState
    struct State: Equatable {
        var kanjis: IdentifiedArrayOf<DisplayWritingKanji.State>
    }
    
    enum Action: Equatable {
        case kanjiSelected(Kanji?)
        case kanji(IdentifiedActionOf<DisplayWritingKanji>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .kanji(.element(id, .select)):
                let selected = state.kanjis[id: id]?.kanji
                return .send(.kanjiSelected(selected))
            default: break
            }
            return .none
        }
        .forEach(\.kanjis, action: \.kanji) { DisplayWritingKanji() }
    }
}

struct WritingKanjiListView: View {
    
    let store: StoreOf<WritingKanjiList>
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(
                    store.scope(state: \.kanjis, action: \.kanji),
                    id: \.state.id
                ) { WritingKanjiCell(store: $0).padding(.horizontal, 5) }
            }
            .padding(.top, 8)
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

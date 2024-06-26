//
//  StudyKanjiSampleView.swift
//  JWords
//
//  Created by JW Moon on 2023/10/02.
//

import ComposableArchitecture
import SwiftUI
import Model

@Reducer
struct StudyKanjiSamples {
    @ObservableState
    struct State: Equatable {
        let kanji: Kanji
        var lists: SwitchBetweenList.State
        
        init(kanji: Kanji, units: [StudyUnit]) {
            self.kanji = kanji
            self.lists = SwitchBetweenList.State(
                units: units,
                frontType: .kanji,
                isLocked: true
            )
        }
    }
    
    enum Action: Equatable {
        case lists(SwitchBetweenList.Action)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
        Scope(state: \.lists, action: \.lists) { SwitchBetweenList() }
    }
}

struct StudyKanjiSampleView: View {
    
    let store: StoreOf<StudyKanjiSamples>
    
    var body: some View {
        AllLists(store: store.scope(state: \.lists, action: \.lists))
        .navigationTitle("\(store.kanji.kanjiText)가 쓰이는 단어")
        #if os(iOS)
        .toolbar(.hidden, for: .tabBar)
        #endif
    }
}

#Preview {
    NavigationStack {
        StudyKanjiSampleView(store: Store(
            initialState: StudyKanjiSamples.State(kanji: .init(index: 0), units: .mock),
            reducer: { StudyKanjiSamples() })
        )
    }
}

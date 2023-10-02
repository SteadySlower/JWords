//
//  StudyKanjiSampleView.swift
//  JWords
//
//  Created by JW Moon on 2023/10/02.
//

import ComposableArchitecture
import SwiftUI

struct StudyKanjiSamples: ReducerProtocol {
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
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        Scope(
            state: \.lists,
            action: /Action.lists,
            child: { SwitchBetweenList() }
        )
    }
}

struct StudyKanjiSampleView: View {
    
    let store: StoreOf<StudyKanjiSamples>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            AllLists(store: store.scope(
                state: \.lists,
                action: StudyKanjiSamples.Action.lists)
            )
        }
    }
}

#Preview {
    NavigationView {
        StudyKanjiSampleView(store: Store(
            initialState: StudyKanjiSamples.State(kanji: .init(index: 0), units: .mock),
            reducer: StudyKanjiSamples())
        )
    }
}

//
//  WritingCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WritingCoordinator {
    @ObservableState
    struct State: Equatable {
        var kanjiSetList: KanjiSetList.State = .init(sets: [])
    }
    
    enum Action {
        case kanjiSetList(KanjiSetList.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.kanjiSetList, action: \.kanjiSetList) { KanjiSetList() }
    }
}

struct WritingCoordinatorView: View {
    
    let store: StoreOf<WritingCoordinator>
    
    var body: some View {
        NavigationStack {
            KanjiSetListView(store: store.scope(
                state: \.kanjiSetList,
                action: \.kanjiSetList)
            )
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

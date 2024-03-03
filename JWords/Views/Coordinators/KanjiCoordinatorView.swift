//
//  KanjiCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KanjiCoordinator {
    @ObservableState
    struct State: Equatable {
        var kanjiList: KanjiList.State = .init(kanjis: [])
    }
    
    enum Action {
        case kanjiList(KanjiList.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.kanjiList, action: \.kanjiList) { KanjiList() }
    }
}

struct KanjiCoordinatorView: View {
    
    let store: StoreOf<KanjiCoordinator>
    
    var body: some View {
        NavigationStack {
            KanjiListView(store: store.scope(
                state: \.kanjiList,
                action: \.kanjiList)
            )
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

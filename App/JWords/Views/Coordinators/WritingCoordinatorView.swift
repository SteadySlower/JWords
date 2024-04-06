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
        var path = StackState<Path.State>()
        var kanjiSetList: KanjiSetList.State = .init(sets: [])
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case writing(WriteKanjis)
    }
    
    enum Action {
        case kanjiSetList(KanjiSetList.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(WritingKanjiClient.self) var wkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .kanjiSetList(.setSelected(let set)):
                let kanjis = try! wkClient.fetch(set)
                state.path.append(.writing(.init(kanjis: kanjis)))
            default: break
            }
            return .none
        }
        .forEach(\.path, action: \.path)
        Scope(state: \.kanjiSetList, action: \.kanjiSetList) { KanjiSetList() }
    }
}

struct WritingCoordinatorView: View {
    
    @Bindable var store: StoreOf<WritingCoordinator>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            KanjiSetListView(store: store.scope(state: \.kanjiSetList, action: \.kanjiSetList))
        } destination: { store in
            switch store.case {
            case .writing(let store):
                WritingKanjisView(store: store)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

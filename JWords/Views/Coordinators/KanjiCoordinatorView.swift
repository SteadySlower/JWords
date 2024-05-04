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
        var path = StackState<Path.State>()
        var kanjiList: KanjiList.State = .init(kanjis: [])
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case samples(StudyKanjiSamples)
    }
    
    enum Action {
        case kanjiList(KanjiList.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(KanjiClient.self) var kanjiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .kanjiList(.kanji(.element(_, .showSamples(let kanji)))):
                let units = try! kanjiClient.kanjiUnits(kanji)
                state.path.append(.samples(StudyKanjiSamples.State(kanji: kanji, units: units)))
            default: break
            }
            return .none
        }
        .forEach(\.path, action: \.path)
        Scope(state: \.kanjiList, action: \.kanjiList) { KanjiList() }
    }
}

struct KanjiCoordinatorView: View {
    
    @Bindable var store: StoreOf<KanjiCoordinator>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            KanjiListView(store: store.scope(state: \.kanjiList, action: \.kanjiList))
        } destination: { store in
            switch store.case {
            case .samples(let store):
                StudyKanjiSampleView(store: store)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

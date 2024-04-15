//
//  SetCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture
import StudyUnitClient

@Reducer
struct SetCoordinator {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var homeList: HomeList.State = .init()
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case studyUnitsInSet(StudyUnitsInSet)
    }
    
    enum Action {
        case homeList(HomeList.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(StudyUnitClient.self) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .homeList(.toStudySet(let set)):
                let units = try! unitClient.fetch(set)
                state.path.append(.studyUnitsInSet(StudyUnitsInSet.State(set: set, units: units)))
            case .path(let action):
                switch action {
                case .element(let id, .studyUnitsInSet(.modals(.unitsMoved))):
                    state.path.pop(from: id)
                default: break
                }
            default: break
            }
            return .none
        }
        .forEach(\.path, action: \.path)
        Scope(state: \.homeList, action: \.homeList) { HomeList() }
    }
}

struct SetCoordinatorView: View {
    
    @Bindable var store: StoreOf<SetCoordinator>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            HomeView(store: store.scope(state: \.homeList, action: \.homeList))
        } destination: { store in
            switch store.case {
            case .studyUnitsInSet(let store):
                StudySetView(store: store)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

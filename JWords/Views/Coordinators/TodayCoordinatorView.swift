//
//  TodayCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture
import StudyUnitClient

@Reducer
struct TodayCoordinator {
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var todayList: TodayList.State = .init()
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case studyUnitsInSet(StudyUnitsInSet)
        case studyUnits(StudyUnits)
        case tutorial(ShowTutorial)
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case todayList(TodayList.Action)
    }
    
    @Dependency(StudyUnitClient.self) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .todayList(let action):
                switch action {
                case .toStudyFilteredUnits(let units):
                    state.path.append(.studyUnits(StudyUnits.State(units: units)))
                case .toStudySet(let set):
                    let units = try! unitClient.fetch(set)
                    state.path.append(.studyUnitsInSet(StudyUnitsInSet.State(set: set, units: units)))
                case .showTutorial:
                    state.path.append(.tutorial(ShowTutorial.State()))
                default: break
                }
            case .path(let action):
                switch action {
                case .element(let id, action: .studyUnitsInSet(.modals(.unitsMoved))):
                    state.path.pop(from: id)
                default: break
                }
            }
            return .none
        }
        .forEach(\.path, action: \.path)
        Scope(state: \.todayList, action: \.todayList) { TodayList() }
    }
    
    
}

struct TodayCoordinatorView: View {
    
    @Bindable var store: StoreOf<TodayCoordinator>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            TodayView(store: store.scope(state: \.todayList, action: \.todayList))
        } destination: { store in
            switch store.case {
            case .studyUnitsInSet(let store):
                StudySetView(store: store)
            case .studyUnits(let store):
                StudyUnitsView(store: store)
            case .tutorial(let store):
                TutorialList(store: store)
            }
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

#Preview {
    TodayCoordinatorView(store: .init(initialState: .init(), reducer: { TodayCoordinator()._printChanges() }))
}


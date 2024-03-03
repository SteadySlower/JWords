//
//  TodayCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct TodayCoordinator {
    @ObservableState
    struct State: Equatable {
        var todayList: TodayList.State = .init()
    }
    
    enum Action {
        case todayList(TodayList.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.todayList, action: \.todayList) { TodayList() }
    }
    
    
}

struct TodayCoordinatorView: View {
    
    let store: StoreOf<TodayCoordinator>
    
    var body: some View {
        NavigationStack {
            TodayView(store: store.scope(state: \.todayList, action: \.todayList)
            )
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

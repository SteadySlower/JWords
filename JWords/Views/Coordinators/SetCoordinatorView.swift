//
//  SetCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SetCoordinator {
    @ObservableState
    struct State: Equatable {
        var homeList: HomeList.State = .init()
    }
    
    enum Action {
        case homeList(HomeList.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.homeList, action: \.homeList) { HomeList() }
    }
}

struct SetCoordinatorView: View {
    
    let store: StoreOf<SetCoordinator>
    
    var body: some View {
        NavigationStack {
            HomeView(store: store.scope(state: \.homeList, action: \.homeList))
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}

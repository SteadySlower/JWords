//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture
import Model
import CommonUI
import StudySetClient
import StudyUnitClient
import Cells
import StudySet

@Reducer
struct HomeList {
    @ObservableState
    struct State: Equatable {
        var studySetList = StudySetList.State()
        
        @Presents var destination: Destination.State?
        
        mutating func clear() {
            studySetList.clear()
            destination = nil
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case addSet(AddSet)
    }
    
    enum Action: Equatable {
        case toAddSet
        case studySetList(StudySetList.Action)
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(StudySetClient.self) var setClient
    @Dependency(StudyUnitClient.self) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toAddSet:
                state.destination = .addSet(.init())
            case .destination(.presented(.addSet(.added(let set)))):
                state.studySetList.sets.insert(set, at: 0)
                state.destination = nil
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
        Scope(state: \.studySetList, action: \.studySetList) { StudySetList() }
    }

}


struct HomeView: View {
    
    @Bindable var store: StoreOf<HomeList>
    
    var body: some View {
        StudySetListView(store: store.scope(
            state: \.studySetList,
            action: \.studySetList)
        )
        .withBannerAD()
        .navigationTitle("모든 단어장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .loadingView(store.studySetList.isLoading)
        .sheet(item: $store.scope(state: \.destination?.addSet, action: \.destination.addSet)) {
            AddSetView(store: $0)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    store.send(.toAddSet)
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .resizable()
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(
                store: Store(
                    initialState: HomeList.State(),
                    reducer: { HomeList()._printChanges() }
                )
            )
        }
    }
}

//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct HomeList {
    @ObservableState
    struct State: Equatable {
        var sets: [StudySet] = []
        var isLoading: Bool = false
        var includeClosed: Bool = false
        
        @Presents var destination: Destination.State?
        
        mutating func clear() {
            sets = []
            destination = nil
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case addSet(AddSet)
    }
    
    enum Action: Equatable {
        case onAppear
        case homeCellTapped(StudySet)
        case updateIncludeClosed(Bool)
        case toAddSet
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.sets = try! setClient.fetch(state.includeClosed)
            case .updateIncludeClosed(let bool):
                state.includeClosed = bool
                return .send(.onAppear)
            case .toAddSet:
                state.destination = .addSet(.init())
            case .destination(.presented(.addSet(.added(let set)))):
                state.sets.insert(set, at: 0)
                state.destination = nil
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }

}

struct HomeView: View {
    
    @Bindable var store: StoreOf<HomeList>
    
    var body: some View {
        VStack {
            Picker("닫힌 단어장", selection: $store.includeClosed.sending(\.updateIncludeClosed)) {
                Text("열린 단어장").tag(false)
                Text("모든 단어장").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 100)
            .padding(.top, 20)
            ScrollView {
                VStack(spacing: 8) {
                    VStack {}.frame(height: 20)
                    ForEach(store.sets, id: \.id) { set in
                        SetCell(
                            title: set.title,
                            schedule: set.schedule,
                            dayFromToday: set.dayFromToday,
                            onTapped: { store.send(.homeCellTapped(set)) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .withBannerAD()
        .navigationTitle("모든 단어장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .loadingView(store.isLoading)
        .onAppear { store.send(.onAppear) }
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

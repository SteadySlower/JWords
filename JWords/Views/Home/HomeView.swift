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
        
        @Presents var studyUnitsInSet: StudyUnitsInSet.State?
        @Presents var addSet: AddSet.State?
        
        mutating func clear() {
            sets = []
            studyUnitsInSet = nil
            addSet = nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case homeCellTapped(StudySet)
        case updateIncludeClosed(Bool)
        case toAddSet
        
        case studyUnitsInSet(PresentationAction<StudyUnitsInSet.Action>)
        case addSet(PresentationAction<AddSet.Action>)
    }
    
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.sets = try! setClient.fetch(state.includeClosed)
            case let .homeCellTapped(set):
                let units = try! unitClient.fetch(set)
                state.studyUnitsInSet = StudyUnitsInSet.State(set: set, units: units)
            case .updateIncludeClosed(let bool):
                state.includeClosed = bool
                return .send(.onAppear)
            case .studyUnitsInSet(.presented(.modals(.unitsMoved))):
                state.studyUnitsInSet = nil
            case .toAddSet:
                state.addSet = AddSet.State()
            case .addSet(.presented(.added(let set))):
                state.sets.insert(set, at: 0)
                state.addSet = nil
            case .addSet(.presented(.cancel)):
                state.addSet = nil
            default: break
            }
            return .none
        }
        .ifLet(\.$studyUnitsInSet, action: \.studyUnitsInSet) { StudyUnitsInSet() }
        .ifLet(\.$addSet, action: \.addSet) { AddSet() }
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
        .navigationDestination(item: $store.scope(state: \.studyUnitsInSet, action: \.studyUnitsInSet)) {
            StudySetView(store: $0)
        }
        .sheet(item: $store.scope(state: \.addSet, action: \.addSet)) {
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

//
//  KanjiSetList.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import SwiftUI
import ComposableArchitecture
import Model
import tcaAPI

@Reducer
struct KanjiSetList {
    @ObservableState
    struct State: Equatable {
        var sets: [KanjiSet] = []
        
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case addKanjiSet(AddKanjiSet)
    }
    
    enum Action: Equatable {
        case fetchSets
        case setSelected(KanjiSet)
        case toAddKanjiSet
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(KanjiSetClient.self) var ksClient
    @Dependency(WritingKanjiClient.self) var wkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                state.sets = try! ksClient.fetch()
            case .toAddKanjiSet:
                state.destination = .addKanjiSet(AddKanjiSet.State())
            case .destination(.presented(.addKanjiSet(.added(let newSet)))):
                state.sets.insert(newSet, at: 0)
                state.destination = nil
            case .destination(.presented(.addKanjiSet(.cancel))):
                state.destination = nil
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct KanjiSetListView: View {
    
    @Bindable var store: StoreOf<KanjiSetList>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                VStack {}
                .frame(height: 20)
                ForEach(store.sets, id: \.id) { set in
                    SetCell(
                        title: set.title,
                        schedule: set.schedule,
                        dayFromToday: set.dayFromToday,
                        onTapped: { store.send(.setSelected(set)) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear { store.send(.fetchSets) }
        .navigationTitle("한자 쓰기장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $store.scope(state: \.destination?.addKanjiSet, action: \.destination.addKanjiSet)) {
            AddKanjiSetView(store: $0)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    store.send(.toAddKanjiSet)
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .resizable()
                        .foregroundColor(.black)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        KanjiSetListView(store: Store(
            initialState: KanjiSetList.State(sets: .mock),
            reducer: { KanjiSetList()._printChanges() })
        )
    }
}

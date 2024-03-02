//
//  KanjiSetList.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KanjiSetList {
    struct State: Equatable {
        var sets: [KanjiSet]
        
        @PresentationState var writeKanjis: WriteKanjis.State?
        @PresentationState var addKanjiSet: AddKanjiSet.State?
    }
    
    enum Action: Equatable {
        case fetchSets
        case setSelected(KanjiSet)
        case toAddKanjiSet
        
        case writeKanjis(PresentationAction<WriteKanjis.Action>)
        case addKanjiSet(PresentationAction<AddKanjiSet.Action>)
    }
    
    @Dependency(\.kanjiSetClient) var ksClient
    @Dependency(\.writingKanjiClient) var wkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                state.sets = try! ksClient.fetch()
            case .setSelected(let set):
                let kanjis = try! wkClient.fetch(set)
                state.writeKanjis = .init(kanjis: kanjis)
            case .toAddKanjiSet:
                state.addKanjiSet = .init()
            case .addKanjiSet(.presented(.added(let newSet))):
                state.sets.insert(newSet, at: 0)
                state.addKanjiSet = nil
            case .addKanjiSet(.presented(.cancel)):
                state.addKanjiSet = nil
            default: break
            }
            return .none
        }
        .ifLet(\.$writeKanjis, action: \.writeKanjis) { WriteKanjis() }
        .ifLet(\.$addKanjiSet, action: \.addKanjiSet) { AddKanjiSet() }
    }
}

struct KanjiSetListView: View {
    
    let store: StoreOf<KanjiSetList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack(spacing: 8) {
                    VStack {}
                    .frame(height: 20)
                    ForEach(vs.sets, id: \.id) { set in
                        SetCell(
                            title: set.title,
                            schedule: set.schedule,
                            dayFromToday: set.dayFromToday,
                            onTapped: { vs.send(.setSelected(set)) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear { vs.send(.fetchSets) }
            .navigationTitle("한자 쓰기장")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(store: store.scope(state: \.$writeKanjis, action: \.writeKanjis)) { WritingKanjisView(store: $0) }
            .sheet(store: store.scope(state: \.$addKanjiSet, action: \.addKanjiSet)) {
                AddKanjiSetView(store: $0)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        vs.send(.toAddKanjiSet)
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .resizable()
                            .foregroundColor(.black)
                    }
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

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
        
        var writeKanjis: WriteKanjis.State?
        var showWriteKanji: Bool { writeKanjis != nil }
        
        var addKanjiSet: AddKanjiSet.State?
        var showAddKanjiSet: Bool { addKanjiSet != nil }
    }
    
    enum Action: Equatable {
        case fetchSets
        case setSelected(KanjiSet)
        case writeKanjis(WriteKanjis.Action)
        case showWriteKanjis(Bool)
        case addKanjiSet(AddKanjiSet.Action)
        case showAddKanjiSet(Bool)
    }
    
    @Dependency(\.kanjiSetClient) var ksClient
    @Dependency(\.writingKanjiClient) var wkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                state.sets = try! ksClient.fetch()
                return .none
            case .setSelected(let set):
                let kanjis = try! wkClient.fetch(set)
                state.writeKanjis = .init(kanjis: kanjis)
                return .none
            case .showWriteKanjis(let show):
                if !show { state.writeKanjis = nil }
                return .none
            case .addKanjiSet(let action):
                switch action {
                case .cancel:
                    state.addKanjiSet = nil
                    return .none
                case .added(let newSet):
                    state.sets.insert(newSet, at: 0)
                    state.addKanjiSet = nil
                    return .none
                default: return .none
                }
            case .showAddKanjiSet(let show):
                state.addKanjiSet = show ? .init() : nil
                return .none
            default: return .none
            }
        }
        .ifLet(\.writeKanjis, action: /Action.writeKanjis) {
            WriteKanjis()
        }
        .ifLet(\.addKanjiSet, action: /Action.addKanjiSet) {
            AddKanjiSet()
        }
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
                    NavigationLink(
                        destination: IfLetStore(
                                store.scope(
                                    state: \.writeKanjis,
                                    action: KanjiSetList.Action.writeKanjis)
                                ) { WritingKanjisView(store: $0) },
                        isActive: vs.binding(
                                    get: \.showWriteKanji,
                                    send: KanjiSetList.Action.showWriteKanjis))
                    { EmptyView() }
                }
                .padding(.horizontal, 20)
            }
            .onAppear { vs.send(.fetchSets) }
            .navigationTitle("한자 쓰기장")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: vs.binding(
                get: \.showAddKanjiSet,
                send: KanjiSetList.Action.showAddKanjiSet)
            ) {
                IfLetStore(store.scope(state: \.addKanjiSet,
                                            action: KanjiSetList.Action.addKanjiSet)
                ) {
                    AddKanjiSetView(store: $0)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        vs.send(.showAddKanjiSet(true))
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
    NavigationView {
        KanjiSetListView(store: Store(
            initialState: KanjiSetList.State(sets: .mock),
            reducer: { KanjiSetList() })
        )
    }
}

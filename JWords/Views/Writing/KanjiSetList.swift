//
//  KanjiSetList.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

struct KanjiSetList: Reducer {
    struct State: Equatable {
        var sets: [KanjiSet]
        
        var writeKanjis: WriteKanjis.State?
        var showWriteKanji: Bool { writeKanjis != nil }
    }
    
    enum Action: Equatable {
        case setSelected(KanjiSet)
        case writeKanjis(WriteKanjis.Action)
        case showWriteKanjis(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setSelected(let set):
                // TODO: add fetch kanjis logic from client
                state.writeKanjis = .init(kanjis: .mock)
                return .none
            default: return .none
            }
        }
        .ifLet(\.writeKanjis, action: /Action.writeKanjis) {
            WriteKanjis()
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
            .navigationTitle("한자 쓰기장")
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

//
//  KanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture

struct KanjiList: ReducerProtocol {
    struct State: Equatable {
        var kanjis: [Kanji] = []
        var editKanji: AddingUnit.State?
        
        var showEditModal: Bool {
            editKanji != nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case editKanji(kanji: Kanji, meaningText: String)
        case wordButtonTapped(in: Kanji)
    }
    
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.kanjis = try! cd.fetchAllKanjis()
                return .none
            default:
                return .none
            }
        }
    }

}

struct KanjiListView: View {
    
    let store: StoreOf<KanjiList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                LazyVStack {
                    ForEach(vs.kanjis, id: \.id) { kanji in
                        KanjiCell(kanji: kanji,
                                  editKanjiMeaning: { vs.send(.editKanji(kanji: $0, meaningText: $1)) },
                                  wordButtonTapped: { vs.send(.wordButtonTapped(in: kanji)) })
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}

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
    }
    
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.kanjis = try! cd.fetchAllKanjis()
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
                        KanjiCell(kanji: kanji)
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}

struct KanjiCell: View {
    
    let kanji: Kanji
    
    var body: some View {
        HStack {
            Text(kanji.kanjiText ?? "")
            Text(kanji.meaningText ?? "")
        }
        .padding(10)
    }
    
}

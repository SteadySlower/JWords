//
//  SearchKanji.swift
//  JWords
//
//  Created by Jong Won Moon on 11/13/23.
//

import SwiftUI
import ComposableArchitecture

struct SearchKanji: Reducer {
    
    struct State: Equatable {
        var query: String = ""
        var result: [Kanji] = []
    }
    
    enum Action: Equatable {
        case updateQuery(String)
        case kanjiSearched([Kanji])
    }
    
    @Dependency(\.kanjiClient) var kanjiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateQuery(let query):
                state.query = query
                guard !query.isEmpty else { return .none }
                if state.query.isHanGeul {
                    return .send(.kanjiSearched(try! kanjiClient.searchWithMeaning(query)))
                } else {
                    return .send(.kanjiSearched(try! kanjiClient.searchWithKanjiText(query)))
                }
            default:
                return .none
            }
        }
    }

}

struct KanjiSearchBar: View {
    
    let store: StoreOf<SearchKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                if vs.query.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.leading, 2)
                }
                TextField("", text: vs.binding(get: \.query, send: SearchKanji.Action.updateQuery))
            }
            .frame(height: 30)
        }
    }
}

#Preview {
    KanjiSearchBar(
        store: .init(
            initialState: SearchKanji.State(),
            reducer: { SearchKanji()._printChanges() }
        )
    )
}

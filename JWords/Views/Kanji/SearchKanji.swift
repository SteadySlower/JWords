//
//  SearchKanji.swift
//  JWords
//
//  Created by Jong Won Moon on 11/13/23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SearchKanji {
    @ObservableState
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
                return .send(.kanjiSearched(try! kanjiClient.search(query)))
            default:
                return .none
            }
        }
    }

}

struct KanjiSearchBar: View {
    
    @Bindable var store: StoreOf<SearchKanji>
    @FocusState private var isEditing: Bool
    
    var body: some View {
        ZStack {
            if store.query.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.leading, 2)
            }
            TextField("", text: $store.query.sending(\.updateQuery))
                .font(.system(size: 30))
                .focused($isEditing)
            if isEditing {
                HStack {
                    Spacer()
                    Button(action: {
                        isEditing = false
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    })
                }
            }
        }
        .frame(height: 50)
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

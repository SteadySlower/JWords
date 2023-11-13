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

    }
    
    enum Action: Equatable {

    }
    
    @Dependency(\.kanjiClient) var kanjiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }

}

struct KanjiSearchBar: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    KanjiSearchBar()
}

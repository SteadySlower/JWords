//
//  AddWritingKanji.swift
//  JWords
//
//  Created by JW Moon on 2/12/24.
//

import SwiftUI
import ComposableArchitecture

struct AddWritingKanji: Reducer {
    struct State: Equatable {
        let kanji: Kanji
        let kanjiSets: [KanjiSet]
    }
    
    enum Action: Equatable {

    }
    
    @Dependency(\.kanjiSetClient) var kanjiSetClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
}

struct AddWritingKanjiView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AddWritingKanjiView()
}

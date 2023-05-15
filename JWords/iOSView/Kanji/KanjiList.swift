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
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

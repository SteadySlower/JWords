//
//  InputKanji.swift
//  JWords
//
//  Created by Jong Won Moon on 11/20/23.
//

import SwiftUI
import ComposableArchitecture

struct InputKanji: Reducer {
    struct State: Equatable {
        var kanji: String
        var meaning: String
        var ondoku: String
        var kundoku: String
    }
    
    enum Action: Equatable {
        case updateKanji(String)
        case updateMeaning(String)
        case updateOndoku(String)
        case updateKundoku(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateKanji(let kanji):
                state.kanji = String(kanji.suffix(1))
                return .none
            case .updateMeaning(let meaning):
                state.meaning = meaning
                return .none
            case .updateOndoku(let ondoku):
                state.ondoku = ondoku
                return .none
            case .updateKundoku(let kundoku):
                state.kundoku = kundoku
                return .none
            default: return .none
            }
        }
    }
    
}

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
        
        init(
            kanji: String = "",
            meaning: String = "",
            ondoku: String = "",
            kundoku: String = ""
        ) {
            self.kanji = kanji
            self.meaning = meaning
            self.ondoku = ondoku
            self.kundoku = kundoku
        }
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
                state.kanji = kanji
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
            }
        }
    }
    
}

struct KanjiInputView: View {
    
    let store: StoreOf<InputKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                HStack {
                    Text("한자")
                    TextField("一", text: vs.binding(
                        get: \.kanji,
                        send: InputKanji.Action.updateKanji)
                    )
                }
                HStack {
                    Text("뜻")
                    TextField("한 일", text: vs.binding(
                        get: \.meaning,
                        send: InputKanji.Action.updateMeaning)
                    )
                }
                HStack {
                    Text("음독")
                    TextField(vs.kanji.isEmpty ? "いち、　いっ" : "",
                      text: vs.binding(
                        get: \.ondoku,
                        send: InputKanji.Action.updateOndoku)
                    )
                }
                HStack {
                    Text("훈독")
                    TextField(vs.kanji.isEmpty ? "ひと, ひとつ" : "",
                      text: vs.binding(
                        get: \.kundoku,
                        send: InputKanji.Action.updateKundoku)
                    )
                }
            }
        }
    }
}

#Preview {
    KanjiInputView(
        store: Store(
            initialState: InputKanji.State(),
            reducer: { InputKanji()._printChanges() }
        )
    )
}

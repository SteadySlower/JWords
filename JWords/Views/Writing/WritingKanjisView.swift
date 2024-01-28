//
//  WritingKanjisView.swift
//  JWords
//
//  Created by JW Moon on 1/21/24.
//

import SwiftUI
import ComposableArchitecture

struct WriteKanjis: Reducer {
    
    struct State: Equatable {
        var kanjis: [Kanji]
        var toWrite: WriteKanji.State = .init()
    }
    
    enum Action: Equatable {
        case kanjiSelected(Kanji)
        case toWrite(WriteKanji.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .kanjiSelected(let kanji):
                state.toWrite.setKanji(kanji)
                return .none
            default: return .none
            }
        }
        Scope(
            state: \.toWrite,
            action: /Action.toWrite,
            child: { WriteKanji() }
        )
    }
    
}

struct WritingKanjisView: View {
    
    let store: StoreOf<WriteKanjis>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            HStack {
                WritingKanjiList(kanjis: vs.kanjis) { vs.send(.kanjiSelected($0)) }
                WritingKanjiView(
                    store: store.scope(
                        state: \.toWrite,
                        action: WriteKanjis.Action.toWrite
                    )
                )
                .padding(.trailing, 10)
            }
        }
    }
}


#Preview {
    WritingKanjisView(store: .init(
        initialState: WriteKanjis.State(kanjis: .mock),
        reducer: { WriteKanjis() }
    )
    )
}

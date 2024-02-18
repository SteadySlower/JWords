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
        var kanjis: WritingKanjiList.State
        var toWrite: WriteKanji.State
        
        init(kanjis: [Kanji]) {
            self.kanjis = WritingKanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: kanjis.map {
                        DisplayWritingKanji.State(kanji: $0)
                    }
                )
            )
            self.toWrite = .init()
        }
    }
    
    enum Action: Equatable {
        case kanjis(WritingKanjiList.Action)
        case toWrite(WriteKanji.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .kanjis(let action):
                switch action {
                case .kanjiSelected(let kanji):
                    state.toWrite.setKanji(kanji)
                    return .none
                default:
                    return .none
                }
            default: return .none
            }
        }
        Scope(
            state: \.toWrite,
            action: /Action.toWrite,
            child: { WriteKanji() }
        )
        Scope(
            state: \.kanjis,
            action: /Action.kanjis,
            child: { WritingKanjiList() }
        )
    }
    
}

struct WritingKanjisView: View {
    
    let store: StoreOf<WriteKanjis>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            HStack {
                WritingKanjiListView(
                    store: store.scope(
                        state: \.kanjis,
                        action: WriteKanjis.Action.kanjis
                    )
                )
                WritingKanjiView(
                    store: store.scope(
                        state: \.toWrite,
                        action: WriteKanjis.Action.toWrite
                    )
                )
                .padding(.trailing, 10)
            }
            #if os(iOS)
            .toolbar(.hidden, for: .tabBar)
            #endif
        }
    }
}


#Preview {
    WritingKanjisView(store: .init(
        initialState: WriteKanjis.State(
            kanjis: .mock
        ),
        reducer: { WriteKanjis() }
    )
    )
}

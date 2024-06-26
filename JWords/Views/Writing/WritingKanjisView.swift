//
//  WritingKanjisView.swift
//  JWords
//
//  Created by JW Moon on 1/21/24.
//

import SwiftUI
import ComposableArchitecture
import Model

@Reducer
struct WriteKanjis {
    @ObservableState
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
        Scope(state: \.toWrite, action: \.toWrite) { WriteKanji() }
        Scope(state: \.kanjis, action: \.kanjis) { WritingKanjiList() }
    }
    
}

struct WritingKanjisView: View {
    
    let store: StoreOf<WriteKanjis>
    
    var body: some View {
        HStack {
            WritingKanjiListView(
                store: store.scope(
                    state: \.kanjis,
                    action: \.kanjis
                )
            )
            WritingKanjiView(
                store: store.scope(
                    state: \.toWrite,
                    action: \.toWrite
                )
            )
            .padding(.trailing, 10)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .tabBar)
        #endif
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

//
//  KanjiCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture
#if os(macOS)
import Cocoa
#endif
import Model
import CommonUI

@Reducer
struct DisplayKanji {
    @ObservableState
    struct State: Equatable, Identifiable {
        let kanji: Kanji
        
        var id: String { kanji.id }
    }
    
    enum Action: Equatable {
        case showSamples(Kanji)
        case edit(Kanji)
        case addToWrite(Kanji)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}

struct KanjiCell: View {
    
    let store: StoreOf<DisplayKanji>
    
    var body: some View {
        Button(action: {
            store.send(.showSamples(store.kanji))
        }, label: {
            HStack {
                VStack {
                    Text(store.kanji.kanjiText)
                        .font(.system(size: 100))
                    Spacer()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(store.kanji.meaningText)
                        .font(.system(size: 30))
                    VStack(alignment: .trailing) {
                        Text("음독")
                            .font(.system(size: 15))
                        Text(store.kanji.ondoku)
                    }
                    VStack(alignment: .trailing) {
                        Text("훈독")
                            .font(.system(size: 15))
                        Text(store.kanji.kundoku)
                    }
                    cellButton
                }
                .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .defaultRectangleBackground()
            .minimumScaleFactor(0.5)
        })
    }
    
    @ViewBuilder
    private var cellButton: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            EmojiButtons(buttons: [
                (emoji: "✏️", action: { store.send(.edit(store.kanji)) }),
                (emoji: "📖", action: { store.send(.addToWrite(store.kanji)) })
            ])
        } else {
            Button("✏️", action: { store.send(.edit(store.kanji)) })
        }
    }
}

#Preview {
    KanjiCell(
        store: .init(
            initialState: DisplayKanji.State(kanji: .init(
                kanjiText: "一",
                meaningText: "한 일",
                ondoku: "いち",
                kundoku: "い",
                studyState: .undefined,
                createdAt: .now,
                usedIn: 1
            )),
            reducer: { DisplayKanji()._printChanges() }
        )
    )
    .frame(height: 150)
    .padding(.horizontal, 20)
}

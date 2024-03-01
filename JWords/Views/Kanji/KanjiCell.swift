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

@Reducer
struct DisplayKanji {
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
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
}

struct KanjiCell: View {
    
    let store: StoreOf<DisplayKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            Button(action: {
                vs.send(.showSamples(vs.kanji))
            }, label: {
                HStack {
                    VStack {
                        Text(vs.kanji.kanjiText)
                            .font(.system(size: 100))
                        Spacer()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(vs.kanji.meaningText)
                            .font(.system(size: 30))
                        VStack(alignment: .trailing) {
                            Text("음독")
                                .font(.system(size: 15))
                            Text(vs.kanji.ondoku)
                        }
                        VStack(alignment: .trailing) {
                            Text("훈독")
                                .font(.system(size: 15))
                            Text(vs.kanji.kundoku)
                        }
                        cellButton(vs: vs)
                    }
                    .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .defaultRectangleBackground()
                .minimumScaleFactor(0.5)
            })
        }
    }
    
    @ViewBuilder
    private func cellButton(vs: ViewStore<DisplayKanji.State, DisplayKanji.Action>) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            EmojiButtons(buttons: [
                (emoji: "✏️", action: { vs.send(.edit(vs.kanji)) }),
                (emoji: "📖", action: { vs.send(.addToWrite(vs.kanji)) })
            ])
        } else {
            Button("✏️", action: { vs.send(.edit(vs.kanji)) })
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

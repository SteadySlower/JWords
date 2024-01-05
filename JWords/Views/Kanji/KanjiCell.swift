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

struct DisplayKanji: Reducer {
    struct State: Equatable {
        let kanji: Kanji
    }
    
    enum Action: Equatable {
        case editButtonTapped
        case kanjiEdited
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
    
    let kanji: Kanji
    
    var body: some View {
        HStack {
            VStack {
                Text(kanji.kanjiText)
                    .font(.system(size: 100))
                Spacer()
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(kanji.meaningText)
                    .font(.system(size: 30))
                VStack(alignment: .trailing) {
                    Text("음독")
                        .font(.system(size: 15))
                    Text(kanji.ondoku)
                }
                VStack(alignment: .trailing) {
                    Text("훈독")
                        .font(.system(size: 15))
                    Text(kanji.kundoku)
                }
            }
            .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .defaultRectangleBackground()
        .minimumScaleFactor(0.5)
    }
}

#Preview {
    KanjiCell(kanji: .init(
        kanjiText: "一",
        meaningText: "한 일",
        ondoku: "いち",
        kundoku: "い",
        createdAt: .now,
        usedIn: 1
    ))
    .frame(height: 100)
    .padding(.horizontal, 20)
}

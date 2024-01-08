//
//  WritingKanjiView.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI

struct WritingKanjiView: View {
    
    let kanji: Kanji
    
    var body: some View {
        KanjiCanvas()
    }
}

#Preview {
    WritingKanjiView(kanji: .init(
        kanjiText: "漢",
        meaningText: "한나라 한",
        ondoku: "kan",
        kundoku: "kan",
        createdAt: .now,
        usedIn: 10)
    )
}

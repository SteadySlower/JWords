//
//  WritingKanjiView.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI

private let KANJI_FRAME_SIZE: CGFloat = 300

struct WritingKanjiView: View {
    
    let kanji: Kanji
    
    var body: some View {
        HStack {
            Text(kanji.kanjiText)
                .font(.system(size: KANJI_FRAME_SIZE))
            KanjiCanvas()
                .frame(width: KANJI_FRAME_SIZE, height: KANJI_FRAME_SIZE)
                .border(.black)
        }
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

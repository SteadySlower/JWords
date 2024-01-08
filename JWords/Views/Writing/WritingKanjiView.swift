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
        VStack {
            VStack(alignment: .leading) {
                Text(kanji.kanjiText)
                    .font(.system(size: KANJI_FRAME_SIZE))
                VStack(alignment: .leading) {
                    Text(kanji.meaningText)
                    Text(kanji.ondoku)
                    Text(kanji.kundoku)
                }
                .font(.system(size: KANJI_FRAME_SIZE / 5))
            }
            KanjiCanvas()
                .frame(width: KANJI_FRAME_SIZE + 50, height: KANJI_FRAME_SIZE + 50)
                .border(.black)
                .padding(.top, 30)
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

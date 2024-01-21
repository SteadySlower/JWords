//
//  WrtingKanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI

struct WritingKanjiList: View {
    
    let kanjis: [Kanji]
    let kanjiTapped: (Kanji) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(kanjis, id: \.id) { kanji in
                    cell(kanji)
                        .onTapGesture { kanjiTapped(kanji) }
                }
            }
        }
    }
}

extension WritingKanjiList {
    
    private func cell(_ kanji: Kanji) -> some View {
        Text(kanji.meaningText)
            .font(.system(size: 50))
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .defaultRectangleBackground()
            .padding(.horizontal, 5)
    }
    
}

#Preview {
    WritingKanjiList(kanjis: .mock) { _ in }
}

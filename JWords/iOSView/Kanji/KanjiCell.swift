//
//  KanjiCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
#if os(macOS)
import Cocoa
#endif

struct KanjiCell: View {
    
    let kanji: Kanji
    
    var body: some View {
        HStack {
            Text(kanji.kanjiText)
                .font(.system(size: 150))
            VStack(spacing: 10) {
                Text(kanji.meaningText)
                    .font(.system(size: 20))
                Text("음독: \(kanji.ondoku)")
                Text("훈독: \(kanji.kundoku)")
            }
        }
        .padding(.vertical, 10)
        .defaultRectangleBackground()
        .padding(.horizontal, 10)
    }

    
}

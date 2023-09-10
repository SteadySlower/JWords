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
            VStack {
                Text(kanji.kanjiText)
                    .font(.system(size: 100))
                Spacer()
            }
            VStack(alignment: .leading) {
                Text(kanji.meaningText)
                    .font(.system(size: 30))
                VStack(alignment: .leading) {
                    Text("음독")
                        .font(.system(size: 15))
                    Text(kanji.ondoku)
                }
                VStack(alignment: .leading) {
                    Text("훈독")
                        .font(.system(size: 15))
                    Text(kanji.kundoku)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .defaultRectangleBackground()
        .minimumScaleFactor(0.5)
    }
}

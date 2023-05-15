//
//  KanjiCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI

struct KanjiCell: View {
    
    let kanji: Kanji
    
    var body: some View {
        HStack {
            VStack(spacing: 10) {
                Text(kanji.kanjiText ?? "")
                    .font(.system(size: 40))
                Text(kanji.meaningText ?? "❓")
                    .font(.system(size: 20))
            }
        }
        .frame(width: Constants.Size.deviceWidth * 0.9)
        .padding(.vertical, 5)
        .border(.black)
        .padding(.vertical, 5)
    }
    
}

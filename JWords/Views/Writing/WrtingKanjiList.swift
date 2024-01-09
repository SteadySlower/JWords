//
//  WrtingKanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI

struct WrtingKanjiList: View {
    
    let kanjis: [Kanji]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(kanjis, id: \.id) { kanji in
                    Text(kanji.meaningText)
                }
            }
        }
    }
}

#Preview {
    WrtingKanjiList(kanjis: .mock)
}

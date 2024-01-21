//
//  WritingKanjisView.swift
//  JWords
//
//  Created by JW Moon on 1/21/24.
//

import SwiftUI

struct WritingKanjisView: View {
    
    let kanjis: [Kanji]
    
    var body: some View {
        HStack {
            WritingKanjiList(kanjis: kanjis)
            WritingKanjiView(kanji: .init(index: 0))
                .padding(.trailing, 10)
        }
    }
}


#Preview {
    WritingKanjisView(kanjis: .mock)
}

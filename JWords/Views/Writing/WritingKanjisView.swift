//
//  WritingKanjisView.swift
//  JWords
//
//  Created by JW Moon on 1/21/24.
//

import SwiftUI

struct WritingKanjisView: View {
    
    @State var toWrite: Kanji?
    @State var showAnswer: Bool = false
    let kanjis: [Kanji]
    
    var body: some View {
        HStack {
            WritingKanjiList(kanjis: kanjis) { toWrite = $0; showAnswer = false }
            WritingKanjiView(kanji: toWrite, showAnswer: $showAnswer)
                .padding(.trailing, 10)
        }
    }
}


#Preview {
    WritingKanjisView(kanjis: .mock)
}

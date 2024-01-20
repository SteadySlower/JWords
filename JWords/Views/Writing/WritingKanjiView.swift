//
//  WritingKanjiView.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI

struct WritingKanjiView: View {
    
    @State var showAnswer: Bool = false
    let kanji: Kanji
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                VStack(alignment: .leading) {
                    Text(showAnswer ? kanji.kanjiText : "?")
                        .font(.system(size: proxy.size.height / 6))
                    VStack(alignment: .leading) {
                        Text(kanji.meaningText)
                        VStack(alignment: .leading) {
                            Text("음독: \(showAnswer ? kanji.ondoku : "???")")
                            Text("훈독: \(showAnswer ? kanji.kundoku : "???")")
                        }
                    }
                    .font(.system(size: proxy.size.height / 15))
                }
                KanjiCanvas()
                    .border(.black)
                    .padding(.top, 30)
                Button(action: {
                    showAnswer.toggle()
                }, label: {
                    Text(showAnswer ? "정답 숨기기" : "정답 보기")
                        .font(.system(size: proxy.size.height / 30))
                })
                .buttonStyle(InputButtonStyle())
            }
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

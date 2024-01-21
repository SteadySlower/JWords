//
//  WritingKanjiView.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import ComposableArchitecture

struct WriteKanji: Reducer {
    
    struct State: Equatable {
    }
    
    enum Action: Equatable {
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
    
}

struct WritingKanjiView: View {
    
    let kanji: Kanji?
    @Binding var showAnswer: Bool
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let kanji = kanji {
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
                    .frame(height: proxy.size.height / 2)
                }
                Spacer()
                VStack {
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
                .frame(height: proxy.size.height / 2)
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
        usedIn: 10),
        showAnswer: .constant(false)
    )
}

#Preview {
    WritingKanjiView(
        kanji: nil,
        showAnswer: .constant(false)
    )
}

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
        var kanji: Kanji?
        var showAnswer: Bool = false
    }
    
    enum Action: Equatable {
        case toggleShowAnswer
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleShowAnswer:
                state.showAnswer.toggle()
                return .none
            }
        }
    }
    
}

struct WritingKanjiView: View {
    
    let store: StoreOf<WriteKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            GeometryReader { proxy in
                VStack {
                    if let kanji = vs.kanji {
                        VStack(alignment: .leading) {
                            Text(vs.showAnswer ? kanji.kanjiText : "?")
                                .font(.system(size: 200))
                            VStack(alignment: .leading) {
                                Text(kanji.meaningText)
                                VStack(alignment: .leading) {
                                    Text("음독: \(vs.showAnswer ? kanji.ondoku : "???")")
                                    Text("훈독: \(vs.showAnswer ? kanji.kundoku : "???")")
                                }
                            }
                            .font(.system(size: 50))
                        }
                        .minimumScaleFactor(0.5)
                    }
                    Spacer()
                    VStack {
                        KanjiCanvas()
                            .border(.black)
                            .padding(.top, 30)
                        Button(action: {
                            vs.send(.toggleShowAnswer)
                        }, label: {
                            Text(vs.showAnswer ? "정답 숨기기" : "정답 보기")
                                .font(.system(size: proxy.size.height / 30))
                        })
                        .buttonStyle(InputButtonStyle())
                    }
                    .frame(height: proxy.size.height / 2 + 50)
                }
            }
        }
    }
}

#Preview {
    WritingKanjiView(store: .init(
        initialState: WriteKanji.State(
            kanji: .init(
                kanjiText: "漢",
                meaningText: "한나라 한",
                ondoku: "kan",
                kundoku: "kan",
                createdAt: .now,
                usedIn: 10),
            showAnswer: false
        ),
        reducer: { WriteKanji() })
    )
}

#Preview {
    WritingKanjiView(store: .init(
        initialState: WriteKanji.State(
            kanji: nil,
            showAnswer: false
        ),
        reducer: { WriteKanji() })
    )
}

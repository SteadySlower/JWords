//
//  WritingKanjiView.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WriteKanji {
    @ObservableState
    struct State: Equatable {
        var kanji: Kanji?
        var showAnswer: Bool = false
        var drawWithPencil = DrawWithPencil.State()
        
        mutating func setKanji(_ kanji: Kanji?) {
            self.kanji = kanji
            self.showAnswer = false
            self.drawWithPencil.resetCanvas()
        }
    }
    
    enum Action: Equatable {
        case toggleShowAnswer
        case drawWithPencel(DrawWithPencil.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleShowAnswer:
                state.showAnswer.toggle()
            default: break
            }
            return .none
        }
        Scope(state: \.drawWithPencil, action: \.drawWithPencel) { DrawWithPencil() }
    }
    
}

struct WritingKanjiView: View {
    
    let store: StoreOf<WriteKanji>
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let kanji = store.kanji {
                    VStack(alignment: .leading) {
                        Text(store.showAnswer ? kanji.kanjiText : "?")
                            .font(.system(size: 200))
                        VStack(alignment: .leading) {
                            Text(kanji.meaningText)
                            VStack(alignment: .leading) {
                                Text("음독: \(store.showAnswer ? kanji.ondoku : "???")")
                                Text("훈독: \(store.showAnswer ? kanji.kundoku : "???")")
                            }
                        }
                        .font(.system(size: 50))
                    }
                    .minimumScaleFactor(0.5)
                }
                Spacer()
                VStack {
                    KanjiCanvas(store: store.scope(
                        state: \.drawWithPencil,
                        action: \.drawWithPencel
                        )
                    )
                    .padding(.top, 30)
                    Button(action: {
                        store.send(.toggleShowAnswer)
                    }, label: {
                        Text(store.showAnswer ? "정답 숨기기" : "정답 보기")
                            .font(.system(size: proxy.size.height / 30))
                    })
                    .buttonStyle(InputButtonStyle())
                }
                .frame(height: proxy.size.height / 2 + 50)
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
                studyState: .undefined,
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

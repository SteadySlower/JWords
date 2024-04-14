//
//  InputKanji.swift
//  JWords
//
//  Created by Jong Won Moon on 11/20/23.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct InputKanji {
    @ObservableState
    struct State: Equatable {
        var kanji: String
        var meaning: String
        var ondoku: String
        var kundoku: String
        let isKanjiEditable: Bool
        
        init(
            kanji: String = "",
            meaning: String = "",
            ondoku: String = "",
            kundoku: String = "",
            isKanjiEditable: Bool = true
        ) {
            self.kanji = kanji
            self.meaning = meaning
            self.ondoku = ondoku
            self.kundoku = kundoku
            self.isKanjiEditable = isKanjiEditable
        }
    }
    
    enum Action: Equatable {
        case setKanji(String)
        case setMeaning(String)
        case setOndoku(String)
        case setKundoku(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setKanji(let kanji):
                guard state.isKanjiEditable else { break }
                state.kanji = kanji
            case .setMeaning(let meaning):
                state.meaning = meaning
            case .setOndoku(let ondoku):
                state.ondoku = ondoku
            case .setKundoku(let kundoku):
                state.kundoku = kundoku
            }
            return .none
        }
    }
    
}

struct KanjiInputView: View {
    
    @Bindable var store: StoreOf<InputKanji>
    
    var body: some View {
        VStack(spacing: 20) {
            inputField(
                title: "한자",
                placeholder: "一",
                text: $store.kanji.sending(\.setKanji)
            ).disabled(!store.isKanjiEditable)
            inputField(
                title: "뜻   ",
                placeholder: "한 일",
                text: $store.meaning.sending(\.setMeaning)
            )
            inputField(
                title: "음독",
                placeholder: store.kanji.isEmpty ? "いち、　いっ" : "",
                text: $store.ondoku.sending(\.setOndoku)
            )
            inputField(
                title: "훈독",
                placeholder: store.kanji.isEmpty ? "ひと, ひとつ" : "",
                text: $store.kundoku.sending(\.setKundoku)
            )
        }
        .padding(.horizontal, 20)
        .padding(.trailing, 30)
    }
    
    private func inputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(alignment: .center) {
            Text(title)
            TextField(placeholder, text: text)
            .background(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.top, 30)
            )
        }
    }
}

#Preview {
    KanjiInputView(
        store: Store(
            initialState: InputKanji.State(),
            reducer: { InputKanji()._printChanges() }
        )
    )
}

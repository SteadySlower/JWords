//
//  WordAddView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct WordAdding: ReducerProtocol {
    struct State: Equatable {
        var meaningText: String = ""
        var wordText: String = ""
        var huriText = EditHuriganaText.State(hurigana: "")
        
        mutating func updateWordText(_ text: String) {
            wordText = text
            let hurigana = HuriganaConverter.shared.convert(text)
            huriText = EditHuriganaText.State(hurigana: hurigana)
        }
    }
    
    enum Action: Equatable {
        case updateWordText(String)
        case editHuriText(action: EditHuriganaText.Action)
        case addButtonTapped
        case cancelButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateWordText(let text):
                state.updateWordText(text)
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.huriText, action: /Action.editHuriText(action:)) {
            EditHuriganaText()
        }
    }

}

struct WordAddView: View {
    
    let store: StoreOf<WordAdding>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                EditableHuriganaText(store: store.scope(
                    state: \.huriText,
                    action: WordAdding.Action.editHuriText(action:))
                )
                TextEditor(text: vs.binding(get: \.wordText, send: WordAdding.Action.updateWordText))
                    .border(.black)
                    .frame(height: 100)
                HStack {
                    Button("추가") { vs.send(.addButtonTapped) }
                    Button("취소") { vs.send(.cancelButtonTapped) }
                }
            }
        }
    }
}

struct WordAddView_Previews: PreviewProvider {
    static var previews: some View {
        WordAddView(store: Store(
            initialState: WordAdding.State(),
            reducer: WordAdding())
        )
    }
}

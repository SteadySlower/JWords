//
//  KanjiInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

struct KanjiInput: Reducer {

    struct State: Equatable {
        var text: String = ""
        var hurigana = EditHuriganaText.State(hurigana: "")
        var isEditing: Bool = true
    }
    
    enum Action: Equatable {
        case updateText(String)
        case onTab
        case convertToHurigana
        case editText
        case huriganaUpdated(String)
        case editHuriText(EditHuriganaText.Action)
    }
    
    private let cd = CoreDataService.shared
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                if text.hasTab { return .send(.onTab) }
                state.text = text
                return .none
            case .convertToHurigana:
                if state.text.isEmpty { return .none }
                let hurigana = HuriganaConverter.shared.convert(state.text)
                state.hurigana = EditHuriganaText.State(hurigana: hurigana)
                state.isEditing = false
                return .send(.huriganaUpdated(state.hurigana.hurigana))
            case .editText:
                state.isEditing = true
                state.hurigana = EditHuriganaText.State(hurigana: "")
                return .send(.huriganaUpdated(state.hurigana.hurigana))
            case .editHuriText(let action):
                switch action {
                case .onHuriUpdated:
                    return .send(.huriganaUpdated(state.hurigana.hurigana))
                default: return .none
                }
            default:
                return .none
            }
        }
        Scope(state: \.hurigana, action: /Action.editHuriText) {
            EditHuriganaText()
        }
    }
    
}

struct KanjiInputField: View {
    
    let store: StoreOf<KanjiInput>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            if vs.isEditing {
                VStack {
                    InputFieldTitle(title: "단어 (앞면)")
                    InputFieldTextEditor(text: vs.binding(get: \.text, send: KanjiInput.Action.updateText))
                    Button("후리가나 변환") {
                        vs.send(.convertToHurigana)
                    }
                    .buttonStyle(InputFieldButtonStyle())
                    .trailingAlignment()
                }
            } else {
                VStack {
                    InputFieldTitle(title: "후리가나 (앞면)")
                    ScrollView {
                        EditableHuriganaText(store: store.scope(
                            state: \.hurigana,
                            action: KanjiInput.Action.editHuriText),
                            fontsize: Constants.Size.UNIT_INPUT_FONT
                        )
                        .padding(.horizontal, 5)
                    }
                    .frame(height: 100)
                    .defaultRectangleBackground()
                    Button("단어 수정") {
                        vs.send(.editText)
                    }
                    .buttonStyle(InputFieldButtonStyle())
                    .trailingAlignment()
                }
            }
        }
    }
}
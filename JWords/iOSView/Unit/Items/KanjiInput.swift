//
//  KanjiInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

struct KanjiInput: ReducerProtocol {

    struct State: Equatable {
        var text: String = ""
        var hurigana = EditHuriganaText.State(hurigana: "")
        var isEditing: Bool = true
    }
    
    enum Action: Equatable {
        case updateText(String)
        case convertToHurigana
        case editText
        case existFound(StudyUnit)
        case editHuriText(EditHuriganaText.Action)
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                state.text = text
                return .none
            case .convertToHurigana:
                if state.text.isEmpty { return .none }
                let hurigana = HuriganaConverter.shared.convert(state.text)
                if let exist = try! cd.checkIfExist(hurigana) {
                    return .task { .existFound(exist) }
                }
                state.hurigana = EditHuriganaText.State(hurigana: hurigana)
                state.isEditing = false
                return .none
            case .editText:
                state.isEditing = true
                state.hurigana = EditHuriganaText.State(hurigana: "")
                return .none
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
    let fontSize: CGFloat
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            if vs.isEditing {
                VStack {
                    InputFieldTitle(title: "단어 (앞면)")
                    InputFieldTextEditor(text: vs.binding(get: \.text, send: KanjiInput.Action.updateText))
                    InputFieldButton(label: "후리가나 변환") {
                        vs.send(.convertToHurigana)
                    }
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
                    InputFieldButton(label: "단어 수정") {
                        vs.send(.editText)
                    }
                    .trailingAlignment()
                }
            }
        }
    }
}

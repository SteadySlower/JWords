//
//  KanjiInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct KanjiInput {
    @ObservableState
    struct State: Equatable {
        var text: String = ""
        var hurigana = EditHuriganaText.State(hurigana: "")
        var isEditing: Bool = true
        
        mutating func convertToHurigana() {
            let hurigana = HuriganaConverter.shared.convert(text)
            self.hurigana = EditHuriganaText.State(hurigana: hurigana)
            isEditing = false
        }
    }
    
    enum Action: Equatable, ViewAction {
        case setText(String)
        case editHuriText(EditHuriganaText.Action)
        case huriganaUpdated(String)
        case onTab
        
        case view(View)
        enum View {
            case convertToHurigana
            case editText
        }
    }
    
    private let cd = CoreDataService.shared
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setText(let text):
                if text.hasTab { return .send(.onTab) }
                state.text = text
            case .view(.convertToHurigana):
                if state.text.isEmpty { return .none }
                state.convertToHurigana()
                return .send(.huriganaUpdated(state.hurigana.hurigana))
            case .view(.editText):
                state.isEditing = true
                state.hurigana = EditHuriganaText.State(hurigana: "")
                return .send(.huriganaUpdated(state.hurigana.hurigana))
            case .editHuriText(.onHuriUpdated):
                return .send(.huriganaUpdated(state.hurigana.hurigana))
            default: break
            }
            return .none
        }
        Scope(state: \.hurigana, action: \.editHuriText) { EditHuriganaText() }
    }
    
}

@ViewAction(for: KanjiInput.self)
struct KanjiInputField: View {
    
    @Bindable var store: StoreOf<KanjiInput>
    
    var body: some View {
        if store.isEditing {
            VStack {
                InputFieldTitle(title: "단어 (앞면)")
                InputFieldTextEditor(text: $store.text.sending(\.setText))
                Button("후리가나 변환") {
                    send(.convertToHurigana)
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
                        action: \.editHuriText),
                        fontsize: Constants.Size.UNIT_INPUT_FONT
                    )
                    .padding(.horizontal, 5)
                }
                .frame(height: 100)
                .defaultRectangleBackground()
                Button("단어 수정") {
                    send(.editText)
                }
                .buttonStyle(InputFieldButtonStyle())
                .trailingAlignment()
            }
        }
    }
}

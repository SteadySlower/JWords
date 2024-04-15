//
//  KanjiInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI
import HuriConverter
import HuriView
import CommonUI
import HuriganaClient

@Reducer
struct KanjiInput {
    @ObservableState
    struct State: Equatable {
        var text: String = ""
        var huris: [Huri] = []
        var isEditing: Bool = true
    }
    
    enum Action: Equatable, ViewAction {
        case setText(String)
        case huriganaUpdated(String)
        case huriganaCleared
        case onTab
        
        case view(View)
        
        @CasePathable
        enum View: Equatable {
            case updateHuri(Huri)
            case convertToHurigana
            case editText
        }
    }
    
    @Dependency(HuriganaClient.self) var hgClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setText(let text):
                if text.hasTab { return .send(.onTab) }
                state.text = text
            case .view(.updateHuri(let huri)):
                state.huris.update(huri)
            case .view(.convertToHurigana):
                if state.text.isEmpty { break }
                let hurigana = hgClient.convert(state.text)
                state.huris = hgClient.convertToHuris(hurigana)
                state.isEditing = false
                return .send(.huriganaUpdated(hurigana))
            case .view(.editText):
                state.isEditing = true
                state.huris = []
                return .send(.huriganaCleared)
            default: break
            }
            return .none
        }
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
                    EditableHuriganaText(
                        huris: store.huris,
                        fontsize: Constants.Size.UNIT_INPUT_FONT,
                        onHuriUpdated: { send(.updateHuri($0)) }
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

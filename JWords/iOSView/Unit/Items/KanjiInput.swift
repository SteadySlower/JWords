//
//  KanjiInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture

struct KanjiInput: ReducerProtocol {

    struct State: Equatable {
        var text: String
        var hurigana: EditHuriganaText.State?
        var isEditing: Bool = true
    }
    
    enum Action: Equatable {
        case updateText(String)
        case convertToHurigana
        case editText
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                state.text = text
                return .none
            case .convertToHurigana:
                if state.text.isEmpty { return .none }
                let hurigana = HuriganaConverter.shared.convert(state.text)
                state.hurigana = EditHuriganaText.State(hurigana: hurigana)
                state.isEditing = false
                return .none
            case .editText:
                state.isEditing = true
                state.hurigana = nil
                return .none
            }
        }
    }
    
}

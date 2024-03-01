//
//  MeaningInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MeaningInput {

    struct State: Equatable {
        var text: String = ""
    }
    
    enum Action: Equatable {
        case updateText(String)
        case onTab
    }
    
    private let cd = CoreDataService.shared
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                if text.hasTab { return .send(.onTab) }
                state.text = text
                return .none
            default: return .none
            }
        }
    }
    
}

struct MeaningInputField: View {
    
    let store: StoreOf<MeaningInput>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                InputFieldTitle(title: "뜻 (뒷면)")
                InputFieldTextEditor(text: vs.binding(
                    get: \.text,
                    send: MeaningInput.Action.updateText)
                )
            }
        }
    }
    
}
    


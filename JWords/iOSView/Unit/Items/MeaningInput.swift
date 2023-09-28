//
//  MeaningInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

struct MeaningInput: ReducerProtocol {

    struct State: Equatable {
        var text: String = ""
    }
    
    enum Action: Equatable {
        case updateText(String)
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                state.text = text
                return .none
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
    


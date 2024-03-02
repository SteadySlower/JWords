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
    @ObservableState
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
    
    @Bindable var store: StoreOf<MeaningInput>
    
    var body: some View {
        VStack {
            InputFieldTitle(title: "뜻 (뒷면)")
            InputFieldTextEditor(text: $store.text.sending(\.updateText))
        }
    }
    
}
    


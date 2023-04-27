//
//  KanjiField.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct AddKanji: ReducerProtocol {
    
    struct State: Equatable {
        var text = ""
    }
    
    enum Action: Equatable {
        case updateText(String)
        case onTab
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                if text.hasTab { return .task { .onTab } }
                state.text = text
                return .none
            case .onTab:
                print("디버그: tab on gana field")
                return .none
            default:
                return .none
            }
        }
    }
}

struct KanjiField: View {
    
    let store: StoreOf<AddKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("한자 입력")
                    .font(.system(size: 20))
                TextEditor(text: vs.binding(
                    get: \.text,
                    send: AddKanji.Action.updateText))
                    .font(.system(size: 30))
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
            }

        }
    }
    
}

struct KanjiField_Previews: PreviewProvider {
    static var previews: some View {
        KanjiField(
            store: Store(
                initialState: AddKanji.State(),
                reducer: AddKanji()._printChanges()
            )
        )
    }
}



//
//  AddKanjiSet.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

struct AddKanjiSet: Reducer {
    struct State: Equatable {
        var title: String = ""
        var ableToAdd: Bool { !title.isEmpty }
    }
    
    enum Action: Equatable {
        case updateTitle(String)
        case add
        case cancel
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateTitle(let title):
                state.title = title
                return .none
            default: return .none
            }
        }
    }
    
}

struct AddKanjiSetView: View {
    
    let store: StoreOf<AddKanjiSet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            InputFieldTitle(title: "한자쓰기장 이름")
            InputSetTextField(
                placeHolder: "한자쓰기 이름",
                text: vs.binding(
                    get: \.title,
                    send: AddKanjiSet.Action.updateTitle)
            )
            HStack {
                Spacer()
                Button("취소") {
                    vs.send(.cancel)
                }
                .buttonStyle(InputButtonStyle())
                Spacer()
                Button("추가") {
                    vs.send(.add)
                }
                .buttonStyle(InputButtonStyle(isAble: vs.ableToAdd))
                .disabled(!vs.ableToAdd)
                Spacer()
            }
        }
    }
}

#Preview {
    AddKanjiSetView(
        store: Store(
            initialState: AddKanjiSet.State(),
            reducer: { AddKanjiSet() }
        )
    )
}

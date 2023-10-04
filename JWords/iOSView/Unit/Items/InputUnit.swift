//
//  InputUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

enum UnitInputField {
    case kanji, meaning
}

struct InputUnit: ReducerProtocol {

    struct State: Equatable {
        @BindingState var focusedField: UnitInputField?
        var kanjiInput = KanjiInput.State()
        var meaningInput = MeaningInput.State()
        
        var ableToAdd: Bool {
            !meaningInput.text.isEmpty
            && !kanjiInput.isEditing
            && !kanjiInput.hurigana.hurigana.isEmpty
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case kanjiInput(KanjiInput.Action)
        case meaningInput(MeaningInput.Action)
        case alreadyExist(StudyUnit?)
    }
    
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .kanjiInput(let action):
                switch action {
                case .huriganaUpdated(let hurigana):
                    let unit = try! unitClient.checkIfExist(hurigana)
                    return .task { .alreadyExist(unit) }
                case .onTab:
                    state.focusedField = .meaning
                    return .none
                default: return .none
                }
            default: return .none
            }
        }
        Scope(state: \.kanjiInput,
              action: /Action.kanjiInput
        ) {
            KanjiInput()
        }
        Scope(state: \.meaningInput,
              action: /Action.meaningInput
        ) {
            MeaningInput()
        }
    }
    
}

struct UnitInputView: View {
    
    let store: StoreOf<InputUnit>
    @FocusState var focusedField: UnitInputField?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 10) {
                KanjiInputField(store: store.scope(
                    state: \.kanjiInput,
                    action: InputUnit.Action.kanjiInput)
                )
                .focused($focusedField, equals: .kanji)
                MeaningInputField(store: store.scope(
                    state: \.meaningInput,
                    action: InputUnit.Action.meaningInput)
                )
                .focused($focusedField, equals: .meaning)

            }
            .synchronize(vs.binding(\.$focusedField), self.$focusedField)
        }
    }
    
}

#Preview {
    UnitInputView(
        store: Store(
            initialState: InputUnit.State(),
            reducer: InputUnit())
     )
}

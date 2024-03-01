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

@Reducer
struct InputUnit {

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
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .kanjiInput(let action):
                switch action {
                case .huriganaUpdated(let hurigana):
                    let unit = try! unitClient.checkIfExist(hurigana)
                    return .send(.alreadyExist(unit))
                case .onTab:
                    state.focusedField = .meaning
                    state.kanjiInput.convertToHurigana()
                    let unit = try! unitClient.checkIfExist(state.kanjiInput.hurigana.hurigana)
                    return .send(.alreadyExist(unit))
                default: return .none
                }
            case .meaningInput(let action):
                switch action {
                case .onTab:
                    state.focusedField = .kanji
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
            .synchronize(vs.$focusedField, $focusedField)
        }
    }
    
}

#Preview {
    UnitInputView(
        store: Store(
            initialState: InputUnit.State(),
            reducer: { InputUnit() })
     )
}

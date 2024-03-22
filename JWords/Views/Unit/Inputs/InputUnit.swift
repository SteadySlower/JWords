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
    @ObservableState
    struct State: Equatable {
        var focusedField: UnitInputField?
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
    
    @Dependency(StudyUnitClient.self) var unitClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .kanjiInput(.huriganaUpdated(let hurigana)):
                let unit = try! unitClient.checkIfExist(hurigana)
                return .send(.alreadyExist(unit))
            case .kanjiInput(.onTab):
                state.focusedField = .meaning
                state.kanjiInput.convertToHurigana()
                let unit = try! unitClient.checkIfExist(state.kanjiInput.hurigana.hurigana)
                return .send(.alreadyExist(unit))
            case .meaningInput(.onTab):
                state.focusedField = .kanji
            default: break
            }
            return .none
        }
        Scope(state: \.kanjiInput, action: \.kanjiInput) { KanjiInput() }
        Scope(state: \.meaningInput, action: \.meaningInput) { MeaningInput() }
    }
    
}

struct UnitInputView: View {
    
    @Bindable var store: StoreOf<InputUnit>
    @FocusState var focusedField: UnitInputField?
    
    var body: some View {
        VStack(spacing: 10) {
            KanjiInputField(store: store.scope(
                state: \.kanjiInput,
                action: \.kanjiInput)
            )
            .focused($focusedField, equals: .kanji)
            MeaningInputField(store: store.scope(
                state: \.meaningInput,
                action: \.meaningInput)
            )
            .focused($focusedField, equals: .meaning)

        }
        .synchronize($store.focusedField, $focusedField)
    }
    
}

#Preview {
    UnitInputView(
        store: Store(
            initialState: InputUnit.State(),
            reducer: { InputUnit() })
     )
}

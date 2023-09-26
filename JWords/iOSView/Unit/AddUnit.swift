//
//  AddUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture
import SwiftUI

struct AddUnit: ReducerProtocol {

    struct State: Equatable {
        var kanjiInput = KanjiInput.State()
        var meaningInput = MeaningInput.State()
        
        var ableToAdd: Bool {
            !meaningInput.text.isEmpty
            && !kanjiInput.isEditing
            && !kanjiInput.hurigana.hurigana.isEmpty
        }
    }
    
    enum Action: Equatable {
        case kanjiInput(KanjiInput.Action)
        case meaningInput(MeaningInput.Action)
        case alreadyExist(StudyUnit)
        case add
        case cancel
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .kanjiInput(let action):
                switch action {
                case .huriganaUpdated(let hurigana):
                    if let unit = try! cd.checkIfExist(hurigana) {
                        return .task { .alreadyExist(unit) }
                    }
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

struct UnitAddView: View {
    
    let store: StoreOf<AddUnit>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 40) {
                KanjiInputField(store: store.scope(
                    state: \.kanjiInput,
                    action: AddUnit.Action.kanjiInput)
                )
                MeaningInputField(store: store.scope(
                    state: \.meaningInput,
                    action: AddUnit.Action.meaningInput)
                )
                HStack(spacing: 100) {
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle(isAble: true))
                    Button("추가") {
                        vs.send(.add)
                    }
                    .buttonStyle(InputButtonStyle(isAble: vs.ableToAdd))
                    .disabled(!vs.ableToAdd)
                }
            }
        }
    }
    
}

#Preview {
     UnitAddView(
        store: Store(
            initialState: AddUnit.State(),
            reducer: AddUnit())
     )
}

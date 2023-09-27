//
//  AddUnitInSet.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI

struct AddUnitInSet: ReducerProtocol {
    
    struct State: Equatable {
        let set: StudySet
        var alreadyExist: StudyUnit?
        var inputUnit: InputUnit.State
    }
    
    enum Action: Equatable {
        case inputUnit(InputUnit.Action)
        case add
        case cancel
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .inputUnit(let action):
                switch action {
                case .alreadyExist(let unit):
                    state.alreadyExist = unit
                    return .none
                default: return .none
                }
            default: return .none
            }
        }
        Scope(state: \.inputUnit, action: /Action.inputUnit) {
            InputUnit()
        }
    }
    
}

struct AddUnitModal: View {
    
    let store: StoreOf<AddUnitInSet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 40) {
                UnitInputView(store: store.scope(
                    state: \.inputUnit,
                    action: AddUnitInSet.Action.inputUnit)
                )
                HStack(spacing: 100) {
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle())
                    Button("추가") {
                        vs.send(.add)
                    }
                    .buttonStyle(InputButtonStyle(isAble: vs.inputUnit.ableToAdd))
                    .disabled(!vs.inputUnit.ableToAdd)
                }
            }
        }
    }
}

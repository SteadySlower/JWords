//
//  MacAddUnitView.swift
//  JWords
//
//  Created by JW Moon on 2023/06/10.
//

import SwiftUI
import ComposableArchitecture

struct SelectSetAddUnit: ReducerProtocol {
    
    struct State: Equatable {
        var selectSet = SelectStudySet.State(pickerName: "단어장 선택")
        var addUnit: AddingUnit.State?
        
        mutating func updateAddUnit() {
            guard let set = selectSet.selectedSet else {
                addUnit = nil
                return
            }
            addUnit = AddingUnit.State(mode: .insert(set: set))
        }
    }
    
    enum Action: Equatable {
        case selectSet(action: SelectStudySet.Action)
        case addUnit(action: AddingUnit.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectSet(action):
                switch action {
                case .idUpdated:
                    state.updateAddUnit()
                default: break
                }
            default:
                break
            }
            return .none
        }
        .ifLet(\.addUnit, action: /Action.addUnit(action:)) {
            AddingUnit()
        }
        Scope(state: \.selectSet, action: /Action.selectSet(action:)) {
            SelectStudySet()
        }
    }
}

struct MacAddUnitView: View {
    
    let store: StoreOf<SelectSetAddUnit>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                StudySetPicker(store: store.scope(
                    state: \.selectSet,
                    action: SelectSetAddUnit.Action.selectSet(action:))
                )
                IfLetStore(store.scope(
                    state: \.addUnit,
                    action: SelectSetAddUnit.Action.addUnit(action:))
                ) { StudyUnitAddView(store: $0) }
            }
        }
    }
}

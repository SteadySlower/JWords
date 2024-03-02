//
//  StudyModals.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

extension View {
    func withListModals(store: StoreOf<ShowModalsInList>) -> some View {
        modifier(ListModals(store: store))
    }
}

@Reducer
struct ShowModalsInList {
    
    struct State: Equatable {
        @PresentationState var editSet: EditSet.State?
        @PresentationState var addUnit: AddUnit.State?
        @PresentationState var editUnit: EditUnit.State?
        @PresentationState var moveUnits: MoveUnits.State?
        
        private mutating func clear() {
            editSet = nil
            addUnit = nil
            editUnit = nil
            moveUnits = nil
        }
        
        mutating func setEditSetModal(_ set: StudySet) {
            clear()
            editSet = EditSet.State(set)
        }
        
        mutating func setAddUnitModal(_ set: StudySet) {
            clear()
            addUnit = AddUnit.State(set: set)
        }
        
        mutating func setEditUnitModal(_ unit: StudyUnit) {
            clear()
            editUnit = EditUnit.State(unit: unit)
        }
        
        mutating func setMoveUnitModal(from set: StudySet, isReview: Bool, toMove units: [StudyUnit]) {
            clear()
            moveUnits = MoveUnits.State(
                fromSet: set,
                isReviewSet: isReview,
                toMoveUnits: units,
                willCloseSet: set.dayFromToday >= 28 ? true : false
            )
        }
    }
    
    enum Action: Equatable {
        case editSet(PresentationAction<EditSet.Action>)
        case addUnit(PresentationAction<AddUnit.Action>)
        case editUnit(PresentationAction<EditUnit.Action>)
        case moveUnits(PresentationAction<MoveUnits.Action>)
        
        case setEdited(StudySet)
        case unitAdded(StudyUnit)
        case unitEdited(StudyUnit)
        case unitsMoved
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .editSet(.presented(let action)):
                switch action {
                case .edited(let set):
                    state.editSet = nil
                    return .send(.setEdited(set))
                case .cancel:
                    state.editSet = nil
                default: break
                }
            case .addUnit(.presented(let action)):
                switch action {
                case .added(let unit):
                    state.addUnit = nil
                    return .send(.unitAdded(unit))
                case .cancel:
                    state.addUnit = nil
                default: break
                }
            case .editUnit(.presented(let action)):
                switch action {
                case .edited(let unit):
                    state.editUnit = nil
                    return .send(.unitEdited(unit))
                case .cancel:
                    state.editUnit = nil
                default: break
                }
            case .moveUnits(.presented(let action)):
                switch action {
                case .onMoved:
                    state.moveUnits = nil
                    return .send(.unitsMoved)
                case .cancelButtonTapped:
                    state.moveUnits = nil
                default: break
                }
            default: break
            }
            return .none
        }
        .ifLet(\.$editSet, action: \.editSet) { EditSet() }
        .ifLet(\.$addUnit, action: \.addUnit) { AddUnit() }
        .ifLet(\.$editUnit, action: \.editUnit) { EditUnit() }
        .ifLet(\.$moveUnits, action: \.moveUnits) { MoveUnits() }
    }

}

struct ListModals: ViewModifier {
    
    let store: StoreOf<ShowModalsInList>
    
    func body(content: Content) -> some View {
        WithViewStore(store, observe: { $0 }) { vs in
            content
                .sheet(store: store.scope(state: \.$editSet, action: \.editSet)) {
                    EditSetView(store: $0)
                }
                .sheet(store: store.scope(state: \.$addUnit, action: \.addUnit)) {
                    AddUnitView(store: $0)
                        .padding(.horizontal, 10)
                        .presentationDetents([.medium])
                }
                .sheet(store: store.scope(state: \.$editUnit, action: \.editUnit)) {
                    EditUnitView(store: $0)
                        .padding(.horizontal, 10)
                        .presentationDetents([.medium])
                }
                .sheet(store: store.scope(state: \.$moveUnits, action: \.moveUnits)) {
                    UnitMoveView(store: $0)
                }
        }
    }
    
}

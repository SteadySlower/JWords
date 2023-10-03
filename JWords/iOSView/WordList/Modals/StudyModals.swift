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

struct ShowModalsInList: ReducerProtocol {
    
    struct State: Equatable {
        var editSet: InputBook.State?
        var addUnit: AddUnit.State?
        var editUnit: EditUnit.State?
        var moveUnits: MoveWords.State?
        
        var showEditSetModal: Bool {
            editSet != nil
        }
        
        var showAddUnitModal: Bool {
            addUnit != nil
        }
        
        var showEditUnitModal: Bool {
            editUnit != nil
        }
        
        var showMoveUnitsModal: Bool {
            moveUnits != nil
        }
        
        private mutating func clear() {
            editSet = nil
            addUnit = nil
            editUnit = nil
            moveUnits = nil
        }
        
        mutating func setEditSetModal(_ set: StudySet) {
            clear()
            editSet = InputBook.State(set: set)
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
            moveUnits = MoveWords.State(fromBook: set, isReviewBook: isReview, toMoveWords: units)
        }
    }
    
    enum Action: Equatable {
        case showEditSetModal(Bool)
        case showAddUnitModal(Bool)
        case showEditUnitModal(Bool)
        case showMoveUnitsModal(Bool)
        
        case editSet(InputBook.Action)
        case addUnit(AddUnit.Action)
        case editUnit(EditUnit.Action)
        case moveUnits(MoveWords.Action)
        
        case setEdited(StudySet)
        case unitAdded(StudyUnit)
        case unitEdited(StudyUnit)
        case unitsMoved
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .showEditSetModal(let show):
                if !show { state.editSet = nil }
                return .none
            case .showAddUnitModal(let show):
                if !show { state.addUnit = nil }
                return .none
            case .showEditUnitModal(let show):
                if !show { state.editUnit = nil }
                return .none
            case .showMoveUnitsModal(let show):
                if !show { state.moveUnits = nil }
                return .none
            case .editSet(let action):
                switch action {
                case .setEdited(let set):
                    state.editSet = nil
                    return .task { .setEdited(set) }
                case .cancelButtonTapped:
                    state.editSet = nil
                    return .none
                default: return .none
                }
            case .addUnit(let action):
                switch action {
                case .added(let unit):
                    state.addUnit = nil
                    return .task { .unitAdded(unit) }
                case .cancel:
                    state.addUnit = nil
                    return .none
                default: return .none
                }
            case .editUnit(let action):
                switch action {
                case .edited(let unit):
                    state.editUnit = nil
                    return .task { .unitEdited(unit) }
                case .cancel:
                    state.editUnit = nil
                    return .none
                default: return .none
                }
            case .moveUnits(let action):
                switch action {
                case .onMoved:
                    state.moveUnits = nil
                    return .task { .unitsMoved }
                case .cancelButtonTapped:
                    state.moveUnits = nil
                    return .none
                default: return .none
                }
            default: return .none
            }
        }
        .ifLet(
            \.editSet,
             action: /Action.editSet
        ) {
            InputBook()
        }
        .ifLet(
            \.addUnit,
             action: /Action.addUnit
        ) {
            AddUnit()
        }
        .ifLet(
            \.editUnit,
             action: /Action.editUnit
        ) {
            EditUnit()
        }
        .ifLet(
            \.moveUnits,
             action: /Action.moveUnits
        ) {
            MoveWords()
        }
    }

}

struct ListModals: ViewModifier {
    
    let store: StoreOf<ShowModalsInList>
    
    func body(content: Content) -> some View {
        WithViewStore(store, observe: { $0 }) { vs in
            content
                .sheet(isPresented: vs.binding(
                    get: \.showEditSetModal,
                    send: ShowModalsInList.Action.showEditSetModal)
                ) {
                    IfLetStore(store.scope(
                        state: \.editSet,
                        action: ShowModalsInList.Action.editSet)
                    ) {
                        WordBookAddModal(store: $0)
                    }
                }
                .sheet(isPresented: vs.binding(
                    get: \.showAddUnitModal,
                    send: ShowModalsInList.Action.showAddUnitModal)
                ) {
                    IfLetStore(store.scope(
                        state: \.addUnit,
                        action: ShowModalsInList.Action.addUnit)
                    ) {
                        AddUnitView(store: $0)
                            .padding(.horizontal, 10)
                            .presentationDetents([.medium])
                    }
                }
                .sheet(isPresented: vs.binding(
                    get: \.showEditUnitModal,
                    send: ShowModalsInList.Action.showEditUnitModal)
                ) {
                    IfLetStore(store.scope(
                        state: \.editUnit,
                        action: ShowModalsInList.Action.editUnit)
                    ) {
                        EditUnitView(store: $0)
                            .padding(.horizontal, 10)
                            .presentationDetents([.medium])
                    }
                }
                .sheet(isPresented: vs.binding(
                    get: \.showMoveUnitsModal,
                    send: ShowModalsInList.Action.showMoveUnitsModal)
                ) {
                    IfLetStore(store.scope(
                        state: \.moveUnits,
                        action: ShowModalsInList.Action.moveUnits)
                    ) {
                        WordMoveView(store: $0)
                    }
                }
        }
    }
    
}

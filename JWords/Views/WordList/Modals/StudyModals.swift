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
    @ObservableState
    struct State: Equatable {
        
        @Presents var destination: Destination.State?
        
        mutating func setEditSetModal(_ set: StudySet) {
            destination = .editSet(.init(set))
        }
        
        mutating func setAddUnitModal(_ set: StudySet) {
            destination = .addUnit(.init(set: set))
        }
        
        mutating func setEditUnitModal(unit: StudyUnit, convertedKanjiText: String) {
            destination = .editUnit(.init(unit: unit, convertedKanjiText: convertedKanjiText))
        }
        
        mutating func setMoveUnitModal(from set: StudySet, isReview: Bool, toMove units: [StudyUnit]) {
            destination = .moveUnits(.init(fromSet: set, isReviewSet: isReview, toMoveUnits: units, willCloseSet: set.dayFromToday >= 28 ? true : false))
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case editSet(EditSet)
        case addUnit(AddUnit)
        case editUnit(EditUnit)
        case moveUnits(MoveUnits)
    }
    
    enum Action: Equatable {
        case setEdited(StudySet)
        case unitAdded(StudyUnit)
        case unitEdited(StudyUnit)
        case unitsMoved
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination(.presented(.editSet(.edited(let set)))):
                state.destination = nil
                return .send(.setEdited(set))
            case .destination(.presented(.addUnit(.added(let unit)))):
                state.destination = nil
                return .send(.unitAdded(unit))
            case .destination(.presented(.editUnit(.edited(let unit)))):
                state.destination = nil
                return .send(.unitEdited(unit))
            case .destination(.presented(.moveUnits(.onMoved))):
                state.destination = nil
                return .send(.unitsMoved)
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }

}

struct ListModals: ViewModifier {
    
    @Bindable var store: StoreOf<ShowModalsInList>
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $store.scope(state: \.destination?.editSet, action: \.destination.editSet)) {
                EditSetView(store: $0)
            }
            .sheet(item: $store.scope(state: \.destination?.addUnit, action: \.destination.addUnit)) {
                AddUnitView(store: $0)
                    .padding(.horizontal, 10)
                    .presentationDetents([.medium])
            }
            .sheet(item: $store.scope(state: \.destination?.editUnit, action: \.destination.editUnit)) {
                EditUnitView(store: $0)
                    .padding(.horizontal, 10)
                    .presentationDetents([.medium])
            }
            .sheet(item: $store.scope(state: \.destination?.moveUnits, action: \.destination.moveUnits)) {
                UnitMoveView(store: $0)
            }
    }
    
}

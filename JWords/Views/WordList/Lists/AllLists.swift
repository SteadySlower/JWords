//
//  SwitchList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/29.
//

import ComposableArchitecture
import SwiftUI
import Model

enum ListType: CaseIterable {
    case study, edit, select, delete
    
    var pickerText: String {
        switch self {
        case .study:
            return "학습"
        case .edit:
            return "수정"
        case .select:
            return "이동"
        case .delete:
            return "삭제"
        }
    }
}

@Reducer
struct SwitchBetweenList {
    @ObservableState
    struct State: Equatable {
        var type: ListType
        private var frontType: FrontType
        private var isLocked: Bool
        
        var study: UnitsList.State
        var edit: EditUnits.State?
        var select: SelectUnits.State?
        var delete: DeleteUnits.State?
        
        var selectedUnits: [StudyUnit]? {
            select?.units.filter({ $0.isSelected }).map { $0.unit }
        }
        
        var notSucceededUnits: [StudyUnit] {
            study._units.filter({ $0.studyState != .success }).map { $0.unit }
        }
        
        init(units: [StudyUnit], frontType: FrontType, isLocked: Bool) {
            self.type = .study
            self.frontType = frontType
            self.isLocked = isLocked
            self.study = UnitsList.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        init(
            study: UnitsList.State,
            edit: EditUnits.State? = nil,
            select: SelectUnits.State? = nil,
            delete: DeleteUnits.State? = nil,
            type: ListType = .study,
            frontType: FrontType = .kanji,
            isLocked: Bool = true
        ) {
            self.study = study
            self.edit = edit
            self.select = select
            self.delete = delete
            self.type = type
            self.frontType = frontType
            self.isLocked = isLocked
        }
        
        mutating func clear() {
            edit = nil
            select = nil
            delete = nil
            type = .study
        }
        
        private mutating func setIsLocked(_ isLocked: Bool) {
            self.isLocked = isLocked
            let units = study._units.map { $0.unit }
            study = UnitsList.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func setFrontType(_ frontType: FrontType) {
            clear()
            self.frontType = frontType
            let units = study._units.map { $0.unit }
            study = UnitsList.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func setFilter(_ filter: UnitFilter) {
            clear()
            if filter == .onlyFail {
                setIsLocked(true)
            } else {
                setIsLocked(false)
            }
            study.setFilter(filter)
        }
        
        mutating func setListType(_ type: ListType) {
            clear()
            self.type = type
            let units = study.units.map { $0.unit }
            switch type {
            case .study:
                study = UnitsList.State(units: units, frontType: frontType, isLocked: isLocked)
            case .edit:
                edit = EditUnits.State(units: units, frontType: frontType)
            case .select:
                select = SelectUnits.State(units: units, frontType: frontType)
            case .delete:
                delete = DeleteUnits.State(units: units, frontType: frontType)
            }
        }
        
        mutating func addNewUnit(_ unit: StudyUnit) {
            clear()
            var units = study._units.map { $0.unit }
            if !units.contains(unit) {
                units.append(unit)
            }
            study = UnitsList.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func updateUnit(_ unit: StudyUnit) {
            clear()
            guard let index = study._units.index(id: unit.id) else { return }
            let newState = StudyOneUnit.State(unit: unit, frontType: frontType)
            study._units.update(newState, at: index)
        }
    }
    
    enum Action: Equatable {
        case study(UnitsList.Action)
        case edit(EditUnits.Action)
        case select(SelectUnits.Action)
        case delete(DeleteUnits.Action)
        
        case toEditUnitSelected(StudyUnit)
        case toDeleteUnitSelected(StudyUnit)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .edit(.toEditUnitSelected(let unit)):
                return .send(.toEditUnitSelected(unit))
            case .delete(.units(.element(let id, .cellTapped))):
                guard let unit = state.study.units.map({ $0.unit }).first(where: { $0.id == id }) else { break }
                return .send(.toDeleteUnitSelected(unit))
            default: break
            }
            return .none
        }
        .ifLet(\.edit, action: \.edit) { EditUnits() }
        .ifLet(\.select, action: \.select) { SelectUnits() }
        .ifLet(\.delete, action: \.delete) { DeleteUnits() }
        Scope(state: \.study, action: \.study) { UnitsList() }
    }
}

struct AllLists: View {
    
    let store: StoreOf<SwitchBetweenList>
    
    var body: some View {
        ScrollView {
            Group {
                switch store.type {
                case .study:
                    StudyList(store: store.scope(state: \.study, action: \.study))
                case .edit:
                    if let editStore = store.scope(state: \.edit, action: \.edit) {
                        EditList(store: editStore)
                    }
                case .select:
                    if let selectStore = store.scope(state: \.select, action: \.select) {
                        SelectList(store: selectStore)
                    }
                case .delete:
                    if let deleteStore = store.scope(state: \.delete, action: \.delete) {
                        DeleteList(store: deleteStore)
                    }
                }
            }
            .padding(.horizontal, Constants.Size.CELL_HORIZONTAL_PADDING)
            .padding(.vertical, 10)
        }
    }
    
}

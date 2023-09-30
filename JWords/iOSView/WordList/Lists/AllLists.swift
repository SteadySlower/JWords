//
//  SwitchList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/29.
//

import ComposableArchitecture
import SwiftUI

enum ListType {
    case study, edit, select, delete
}

struct SwitchBetweenList: ReducerProtocol {
    struct State: Equatable {
        
        var type: ListType
        private var frontType: FrontType
        private var isLocked: Bool
        
        var study: StudyWords.State
        var edit: EditWords.State?
        var select: SelectWords.State?
        var delete: DeleteWords.State?
        
        var selectedUnits: [StudyUnit]? {
            select?.words.filter({ $0.isSelected }).map { $0.unit }
        }
        
        var notSucceededUnits: [StudyUnit] {
            study._units.filter({ $0.studyState != .success }).map { $0.unit }
        }
        
        init(units: [StudyUnit], frontType: FrontType, isLocked: Bool) {
            self.type = .study
            self.frontType = frontType
            self.isLocked = isLocked
            self.study = StudyWords.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        private mutating func clear() {
            edit = nil
            select = nil
            delete = nil
            type = .study
        }
        
        private mutating func setIsLocked(_ isLocked: Bool) {
            self.isLocked = isLocked
            let units = study._units.map { $0.unit }
            study = StudyWords.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func shuffle() {
            clear()
            study.shuffle()
        }
        
        mutating func setFrontType(_ frontType: FrontType) {
            clear()
            self.frontType = frontType
            let units = study._units.map { $0.unit }
            study = StudyWords.State(units: units, frontType: frontType, isLocked: isLocked)
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
                study = StudyWords.State(units: units, frontType: frontType, isLocked: isLocked)
            case .edit:
                edit = EditWords.State(words: units, frontType: frontType)
            case .select:
                select = SelectWords.State(words: units, frontType: frontType)
            case .delete:
                delete = DeleteWords.State(words: units, frontType: frontType)
            }
        }
        
        mutating func addNewUnit(_ unit: StudyUnit) {
            clear()
            var units = study._units.map { $0.unit }
            if !units.contains(unit) {
                units.append(unit)
            }
            study = StudyWords.State(units: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func updateUnit(_ unit: StudyUnit) {
            clear()
            guard let index = study._units.index(id: unit.id) else { return }
            let newState = StudyWord.State(unit: unit, frontType: frontType)
            study._units.update(newState, at: index)
        }
    }
    
    enum Action: Equatable {
        case study(StudyWords.Action)
        case edit(EditWords.Action)
        case select(SelectWords.Action)
        case delete(DeleteWords.Action)
        
        case toEditUnitSelected(StudyUnit)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .edit(let action):
                switch action {
                case .toEditUnitSelected(let unit):
                    return .task { .toEditUnitSelected(unit) }
                default: return .none
                }
            default: return .none
            }
        }
        .ifLet(\.edit, action: /Action.edit) {
            EditWords()
        }
        .ifLet(\.select, action: /Action.select) {
            SelectWords()
        }
        .ifLet(\.delete, action: /Action.delete) {
            DeleteWords()
        }
        Scope(state: \.study, action: /Action.study) {
            StudyWords()
        }
    }
}

struct AllLists: View {
    
    let store: StoreOf<SwitchBetweenList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                Group {
                    switch vs.type {
                    case .study:
                        StudyList(store: store.scope(
                            state: \.study,
                            action: SwitchBetweenList.Action.study)
                        )
                    case .edit:
                        IfLetStore(store.scope(
                            state: \.edit,
                            action: SwitchBetweenList.Action.edit)
                        ) {
                            EditList(store: $0)
                        }
                    case .select:
                        IfLetStore(store.scope(
                            state: \.select,
                            action: SwitchBetweenList.Action.select)
                        ) {
                            SelectList(store: $0)
                        }
                    case .delete:
                        IfLetStore(store.scope(
                            state: \.delete,
                            action: SwitchBetweenList.Action.delete)
                        ) {
                            DeleteList(store: $0)
                        }
                    }
                }
                .padding(.horizontal, Constants.Size.CELL_HORIZONTAL_PADDING)
                .padding(.vertical, 10)
            }
        }
    }
    
}

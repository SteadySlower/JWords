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
    }
    
    enum Action: Equatable {
        case study(StudyWords.Action)
        case edit(EditWords.Action)
        case select(SelectWords.Action)
        case delete(DeleteWords.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
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
    }
    
}

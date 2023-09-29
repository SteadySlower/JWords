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
        
        private let _units: [StudyUnit]
        private var units: [StudyUnit]
        private var filter: UnitFilter
        var type: ListType
        private var frontType: FrontType
        private var isLocked: Bool
        
        var study: StudyWords.State?
        var edit: EditWords.State?
        var select: SelectWords.State?
        var delete: DeleteWords.State?
        
        init(units: [StudyUnit], frontType: FrontType, isLocked: Bool) {
            self._units = units
            self.units = units
            self.filter = .all
            self.type = .study
            self.frontType = frontType
            self.isLocked = isLocked
            self.study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
        }
        
        private mutating func clear() {
            study = nil
            edit = nil
            select = nil
            delete = nil
            type = .study
        }
        
        mutating func shuffle() {
            clear()
            units = units.shuffled()
            study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func setFrontType(_ frontType: FrontType) {
            clear()
            self.frontType = frontType
            study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func setFilter(_ filter: UnitFilter) {
            clear()
            switch filter {
            case .all:
                units = _units
            case .excludeSuccess:
                units = _units.filter { $0.studyState != .success }
            case .onlyFail:
                units = _units.filter { $0.studyState == .fail }
            }
            study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func setIsLocked(_ isLocked: Bool) {
            clear()
            self.isLocked = isLocked
            study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func setListType(_ type: ListType) {
            clear()
            self.type = type
            switch type {
            case .study:
                study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
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
        .ifLet(\.study, action: /Action.study) {
            StudyWords()
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
    }
}

struct AllLists: View {
    
    let store: StoreOf<SwitchBetweenList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            switch vs.type {
            case .study:
                IfLetStore(store.scope(
                    state: \.study,
                    action: SwitchBetweenList.Action.study)
                ) {
                    StudyList(store: $0)
                }
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

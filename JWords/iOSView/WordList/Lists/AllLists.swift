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
        
        private var units: [StudyUnit]
        var type: ListType
        private let frontType: FrontType
        private let isLocked: Bool
        
        var study: StudyWords.State?
        var edit: EditWords.State?
        var select: SelectWords.State?
        var delete: DeleteWords.State?
        
        init(units: [StudyUnit], frontType: FrontType, isLocked: Bool) {
            self.units = units
            self.type = .study
            self.frontType = frontType
            self.isLocked = isLocked
            self.study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
        }
        
        mutating func shuffle() {
            guard type == .study else { return }
            units = units.shuffled()
            study = StudyWords.State(words: units, frontType: frontType, isLocked: isLocked)
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

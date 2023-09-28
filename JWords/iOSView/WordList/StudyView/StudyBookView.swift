//
//  StudyBookView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct StudyBook: ReducerProtocol {
    struct State: Equatable {
        let book: StudySet
        var studyList: StudyWords.State
        var editList: EditWords.State?
        var selectionList: SelectWords.State?
        var deleteList: DeleteWords.State?
        var setting: StudySetting.State
    }
    
    enum Action: Equatable {
        case studyList(StudyWords.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        Scope(
            state: \.studyList,
            action: /Action.studyList,
            child: { StudyWords() }
        )
    }
}

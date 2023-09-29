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
        let set: StudySet
        var studyList: StudyWords.State
        var editList: EditWords.State?
        var selectionList: SelectWords.State?
        var deleteList: DeleteWords.State?
        var setting: StudySetting.State
        var modals = ShowModalsInList.State()
        var tools = StudyTools.State(activeButtons: [.book, .shuffle, .setting])
        
        var showSideBar = false
        
        init(set: StudySet, units: [StudyUnit]) {
            self.set = set
            self.studyList = StudyWords.State(words: units, frontType: set.preferredFrontType, isLocked: false)
            self.setting = .init(set: set, frontType: set.preferredFrontType)
        }
    }
    
    enum Action: Equatable {
        case studyList(StudyWords.Action)
        case modals(ShowModalsInList.Action)
        case showSideBar(Bool)
        case setting(StudySetting.Action)
        case tools(StudyTools.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .showSideBar(let show):
                state.showSideBar = show
                return .none
            case .tools(let action):
                switch action {
                case .book:
                    return .none
                case .shuffle:
                    state.studyList.shuffleWords()
                    return .none
                case .setting:
                    state.showSideBar = true
                    return .none
                }
            default: return .none
            }
        }
        Scope(
            state: \.studyList,
            action: /Action.studyList,
            child: { StudyWords() }
        )
        Scope(
            state: \.modals,
            action: /Action.modals,
            child: { ShowModalsInList() }
        )
        Scope(
            state: \.tools,
            action: /Action.tools,
            child: { StudyTools() }
        )

    }
}

struct StudyBookView: View {
    
    let store: StoreOf<StudyBook>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            StudyList(store: store.scope(
                state: \.studyList,
                action: StudyBook.Action.studyList)
            )
            .sideBar(showSideBar: vs.binding(
                get: \.showSideBar,
                send: StudyBook.Action.showSideBar)
            ) {
                SettingSideBar(store: store.scope(
                    state: \.setting,
                    action: StudyBook.Action.setting)
                )
            }
            .withListModals(store: store.scope(
                state: \.modals,
                action: StudyBook.Action.modals)
            )
            #if os(iOS)
            .toolbar {
                ToolbarItem {
                    StudyToolBarButtons(store: store.scope(
                        state: \.tools,
                        action: StudyBook.Action.tools)
                    )
                }
            }
            #endif
        }
    }
}

#Preview {
    NavigationView {
        StudyBookView(store: Store(
            initialState: StudyBook.State(
                set: .init(index: 0),
                units: .mock),
            reducer: StudyBook())
        )
    }
}

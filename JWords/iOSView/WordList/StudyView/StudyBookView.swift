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
        var lists: SwitchBetweenList.State
        var setting: StudySetting.State
        var modals = ShowModalsInList.State()
        var tools = StudyTools.State(activeButtons: [.book, .shuffle, .setting])
        
        var showSideBar = false
        
        init(set: StudySet, units: [StudyUnit]) {
            self.set = set
            self.lists = SwitchBetweenList.State(units: units, frontType: set.preferredFrontType, isLocked: false)
            self.setting = .init(set: set, frontType: set.preferredFrontType)
        }
    }
    
    enum Action: Equatable {
        case lists(SwitchBetweenList.Action)
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
                    state.lists.shuffle()
                    return .none
                case .setting:
                    state.showSideBar.toggle()
                    return .none
                }
            case .setting(let action):
                switch action {
                case .setFilter(let filter):
                    state.lists.setFilter(filter)
                case .setFrontType(let frontType):
                    state.lists.setFrontType(frontType)
                case .setListType(let listType):
                    state.lists.setListType(listType)
                default: return .none
                }
                return .task { .showSideBar(false) }
            default: return .none
            }
        }
        Scope(
            state: \.lists,
            action: /Action.lists,
            child: { SwitchBetweenList() }
        )
        Scope(
            state: \.setting,
            action: /Action.setting,
            child: { StudySetting() }
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
            AllLists(store: store.scope(
                state: \.lists,
                action: StudyBook.Action.lists)
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
            reducer: StudyBook()._printChanges())
        )
    }
}

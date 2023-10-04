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
        var set: StudySet
        var lists: SwitchBetweenList.State
        var setting: StudySetting.State
        var modals = ShowModalsInList.State()
        var tools = StudyTools.State(activeButtons: [.book, .shuffle, .setting])
        
        var showSideBar = false
        
        init(set: StudySet, units: [StudyUnit]) {
            self.set = set
            self.lists = SwitchBetweenList.State(
                units: units,
                frontType: set.preferredFrontType,
                isLocked: false
            )
            self.setting = .init(
                showSetEditButtons: true,
                frontType: set.preferredFrontType,
                selectableListType: [.study, .edit, .select, .delete]
            )
        }
    }
    
    enum Action: Equatable {
        case lists(SwitchBetweenList.Action)
        case modals(ShowModalsInList.Action)
        case showSideBar(Bool)
        case setting(StudySetting.Action)
        case tools(StudyTools.Action)
        case dismiss
    }
    
    @Dependency(\.scheduleClient) var scheduleClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .lists(let action):
                switch action {
                case .toEditUnitSelected(let unit):
                    state.modals.setEditUnitModal(unit)
                    return .none
                default: return .none
                }
            case .showSideBar(let show):
                state.showSideBar = show
                return .none
            case .tools(let action):
                switch action {
                case .book:
                    if let selected = state.lists.selectedUnits {
                        state.modals.setMoveUnitModal(from: state.set, isReview: false, toMove: selected)
                    } else {
                        let isReviewBook = scheduleClient.fetch().reviewIDs.contains(where: { $0 == state.set.id })
                        state.modals.setMoveUnitModal(from: state.set, isReview: isReviewBook, toMove: state.lists.notSucceededUnits)
                    }
                    return .none
                case .shuffle:
                    state.lists.shuffle()
                    return .none
                case .setting:
                    state.showSideBar.toggle()
                    return .none
                }
            case .modals(let action):
                switch action {
                case .setEdited(let set):
                    state.set = set
                    return .none
                case .unitAdded(let unit):
                    state.lists.addNewUnit(unit)
                    return .none
                case .unitEdited(let unit):
                    state.lists.updateUnit(unit)
                    state.setting.listType = .study
                    return .none
                case .unitsMoved:
                    return .task { .dismiss }
                default: return .none
                }
            case .setting(let action):
                switch action {
                case .wordBookEditButtonTapped:
                    state.modals.setEditSetModal(state.set)
                case .wordAddButtonTapped:
                    state.modals.setAddUnitModal(state.set)
                case .setFilter(let filter):
                    state.lists.setFilter(filter)
                case .setFrontType(let frontType):
                    state.lists.setFrontType(frontType)
                case .setListType(let listType):
                    state.lists.setListType(listType)
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
            .navigationTitle(vs.set.title)
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

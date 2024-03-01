//
//  StudySetView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct StudyUnitsInSet {
    struct State: Equatable {
        var set: StudySet
        var lists: SwitchBetweenList.State
        var setting: StudySetting.State
        var modals = ShowModalsInList.State()
        var tools = StudyTools.State(activeButtons: [.set, .shuffle, .setting])
        
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
        
        init(
            set: StudySet,
            lists: SwitchBetweenList.State
        ) {
            self.set = set
            self.lists = lists
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
    @Dependency(\.utilClient) var utilClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .lists(.toEditUnitSelected(let unit)):
                state.modals.setEditUnitModal(unit)
            case .showSideBar(let show):
                state.showSideBar = show
            case .tools(let action):
                switch action {
                case .set:
                    if let selected = state.lists.selectedUnits {
                        state.modals.setMoveUnitModal(from: state.set, isReview: false, toMove: selected)
                    } else {
                        let isReviewSet = scheduleClient.isReview(state.set)
                        state.modals.setMoveUnitModal(from: state.set, isReview: isReviewSet, toMove: state.lists.notSucceededUnits)
                    }
                case .shuffle:
                    let units = state.lists.study._units.map { $0.unit }
                    let shuffled = utilClient.shuffleUnits(units)
                    state.lists.study = .init(units: shuffled, frontType: state.setting.frontType, isLocked: false)
                    state.lists.clear()
                case .setting:
                    state.showSideBar.toggle()
                }
            case .modals(let action):
                switch action {
                case .setEdited(let set):
                    state.set = set
                case .unitAdded(let unit):
                    state.lists.addNewUnit(unit)
                case .unitEdited(let unit):
                    state.lists.updateUnit(unit)
                    state.setting.listType = .study
                case .unitsMoved:
                    return .send(.dismiss)
                default: break
                }
            case .setting(let action):
                switch action {
                case .setEditButtonTapped:
                    state.modals.setEditSetModal(state.set)
                case .unitAddButtonTapped:
                    state.modals.setAddUnitModal(state.set)
                case .setFilter(let filter):
                    state.lists.setFilter(filter)
                case .setFrontType(let frontType):
                    state.lists.setFrontType(frontType)
                case .setListType(let listType):
                    state.lists.setListType(listType)
                }
                state.showSideBar = false
            default: break
            }
            return .none
        }
        Scope(state: \.lists, action: \.lists) { SwitchBetweenList() }
        Scope(state: \.setting, action: \.setting) { StudySetting() }
        Scope(state: \.modals, action: \.modals) { ShowModalsInList() }
        Scope(state: \.tools, action: \.tools) { StudyTools() }

    }
}

struct StudySetView: View {
    
    let store: StoreOf<StudyUnitsInSet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            AllLists(store: store.scope(
                state: \.lists,
                action: \.lists)
            )
            .sideBar(showSideBar: vs.binding(
                get: \.showSideBar,
                send: StudyUnitsInSet.Action.showSideBar)
            ) {
                SettingSideBar(store: store.scope(
                    state: \.setting,
                    action: \.setting)
                )
            }
            .withListModals(store: store.scope(
                state: \.modals,
                action: \.modals)
            )
            .navigationTitle(vs.set.title)
            #if os(iOS)
            .toolbar {
                ToolbarItem {
                    StudyToolBarButtons(store: store.scope(
                        state: \.tools,
                        action: \.tools)
                    )
                }
            }
            .toolbar(.hidden, for: .tabBar)
            #endif
        }
    }
}

#Preview {
    NavigationView {
        StudySetView(store: Store(
            initialState: StudyUnitsInSet.State(
                set: .init(index: 0),
                units: .mock),
            reducer: { StudyUnitsInSet()._printChanges() })
        )
    }
}

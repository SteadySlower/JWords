//
//  StudyWordsView.swift
//  JWords
//
//  Created by JW Moon on 2023/10/01.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct StudyUnits {
    struct State: Equatable {
        var lists: SwitchBetweenList.State
        var setting: StudySetting.State
        var modals = ShowModalsInList.State()
        var tools = StudyTools.State(activeButtons: [.shuffle, .setting])
        
        var showSideBar = false
        
        init(units: [StudyUnit]) {
            self.lists = SwitchBetweenList.State(
                units: units,
                frontType: .kanji,
                isLocked: false
            )
            self.setting = .init(
                showSetEditButtons: false,
                frontType: .kanji,
                selectableListType: [.study, .edit]
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
    
    @Dependency(\.utilClient) var utilClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .lists(.toEditUnitSelected(let unit)):
                state.modals.setEditUnitModal(unit)
            case .showSideBar(let show):
                state.showSideBar = show
            case .tools(.shuffle):
                let units = state.lists.study._units.map { $0.unit }
                let shuffled = utilClient.shuffleUnits(units)
                state.lists.study = .init(units: shuffled, frontType: state.setting.frontType, isLocked: false)
                state.lists.clear()
            case .tools(.setting):
                state.showSideBar.toggle()
            case .modals(.unitEdited(let unit)):
                state.lists.updateUnit(unit)
                state.setting.listType = .study
            case .setting(let action):
                switch action {
                case .setFilter(let filter):
                    state.lists.setFilter(filter)
                case .setFrontType(let frontType):
                    state.lists.setFrontType(frontType)
                case .setListType(let listType):
                    state.lists.setListType(listType)
                default: break
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

struct StudyUnitsView: View {
    
    let store: StoreOf<StudyUnits>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            AllLists(store: store.scope(
                state: \.lists,
                action: StudyUnits.Action.lists)
            )
            .sideBar(showSideBar: vs.binding(
                get: \.showSideBar,
                send: StudyUnits.Action.showSideBar)
            ) {
                SettingSideBar(store: store.scope(
                    state: \.setting,
                    action: StudyUnits.Action.setting)
                )
            }
            .withListModals(store: store.scope(
                state: \.modals,
                action: StudyUnits.Action.modals)
            )
            .navigationTitle("틀린 단어 모아보기")
            #if os(iOS)
            .toolbar {
                ToolbarItem {
                    StudyToolBarButtons(store: store.scope(
                        state: \.tools,
                        action: StudyUnits.Action.tools)
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
        StudyUnitsView(store: Store(
            initialState: StudyUnits.State(units: .mock),
            reducer: { StudyUnits() })
        )
    }
}

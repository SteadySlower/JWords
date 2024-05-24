//
//  StudySetView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI
import Model
import SideBar
import ScheduleClient
import UtilClient
import HuriganaClient
import StudyUnitClient

@Reducer
struct StudyUnitsInSet {
    @ObservableState
    struct State: Equatable {
        var set: StudySet
        var lists: SwitchBetweenList.State
        var setting: StudySetting.State
        var modals = ShowModalsInList.State()
        var tools = StudyTools.State(activeButtons: [.set, .shuffle, .setting])
        
        var showSideBar = false
        
        @Presents var alert: AlertState<AlertAction>?
        
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
        
        mutating func setDeleteAlert(_ unit: StudyUnit) {
            alert = AlertState<AlertAction> {
                TextState("단어 삭제")
            } actions: {
                ButtonState(action: .delete(unit)) {
                    TextState("삭제")
                }
                ButtonState(role: .destructive, action: .completeDelete(unit)) {
                    TextState("완전 삭제")
                }
            } message: {
                TextState("선택된 단어를 현재 단어장에서 삭제합니다.\n삭제: 다른 단어장에서는 삭제되지 않습니다.\n완전 삭제: 다른 모든 단어장에서도 삭제됩니다.")
            }
        }
    }
    
    enum Action: Equatable {
        case lists(SwitchBetweenList.Action)
        case modals(ShowModalsInList.Action)
        case showSideBar(Bool)
        case setting(StudySetting.Action)
        case tools(StudyTools.Action)
        case alert(PresentationAction<AlertAction>)
    }
    
    enum AlertAction: Equatable {
        case delete(StudyUnit)
        case completeDelete(StudyUnit)
    }
    
    @Dependency(ScheduleClient.self) var scheduleClient
    @Dependency(UtilClient.self) var utilClient
    @Dependency(HuriganaClient.self) var hgClient
    @Dependency(StudyUnitClient.self) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .lists(.toEditUnitSelected(let unit)):
                let convertedKanjiText = hgClient.huriToKanjiText(unit.kanjiText)
                let huris = hgClient.convertToHuris(unit.kanjiText)
                state.modals.setEditUnitModal(unit: unit, convertedKanjiText: convertedKanjiText, huris: huris)
            case .lists(.toDeleteUnitSelected(let unit)):
                state.setDeleteAlert(unit)
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
            case .alert(let action):
                switch action {
                case .presented(.delete(let unit)):
                    try! unitClient.delete(unit, state.set)
                    state.lists.study.onDeleted(unit)
                    state.lists.setListType(.study)
                case .presented(.completeDelete(let unit)):
                    try! unitClient.completeDelete(unit)
                    state.lists.study.onDeleted(unit)
                    state.lists.setListType(.study)
                default: break
                }
            default: break
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
        Scope(state: \.lists, action: \.lists) { SwitchBetweenList() }
        Scope(state: \.setting, action: \.setting) { StudySetting() }
        Scope(state: \.modals, action: \.modals) { ShowModalsInList() }
        Scope(state: \.tools, action: \.tools) { StudyTools() }

    }
}

struct StudySetView: View {
    
    @Bindable var store: StoreOf<StudyUnitsInSet>
    
    var body: some View {
        AllLists(store: store.scope(state: \.lists, action: \.lists))
        .sideBar(
            deviceWidth: Constants.Size.deviceWidth,
            showSideBar: $store.showSideBar.sending(\.showSideBar)
        ) {
            SettingSideBar(store: store.scope(state: \.setting, action: \.setting))
        }
        .withListModals(store: store.scope(state: \.modals, action: \.modals))
        .alert($store.scope(state: \.alert, action: \.alert))
        .navigationTitle(store.set.title)
        #if os(iOS)
        .toolbar { ToolbarItem { StudyToolBarButtons(store: store.scope(state: \.tools, action: \.tools)) } }
        .toolbar(.hidden, for: .tabBar)
        #endif
    }
}

#Preview {
    NavigationStack {
        StudySetView(store: Store(
            initialState: StudyUnitsInSet.State(
                set: .init(index: 0),
                units: .mock),
            reducer: { StudyUnitsInSet()._printChanges() })
        )
    }
}

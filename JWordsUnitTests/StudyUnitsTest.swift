//
//  StudyUnitsTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/22/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class StudyUnitsTest: XCTestCase {
    
    func test_lists_toEditUnitSelected() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(.lists(.toEditUnitSelected(unit))) {
            $0.modals.setEditUnitModal(unit)
        }
    }
    
    func test_showSideBar() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        
        var showSideBar = store.state.showSideBar
        
        for _ in 0..<Random.int(from: 1, to: 100) {
            showSideBar.toggle()
            await store.send(.showSideBar(showSideBar)) {
                $0.showSideBar = showSideBar
            }
        }
    }
    
    func test_tools_shuffle() async {
        let shuffled: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() },
            withDependencies: {
                $0.utilClient.shuffleUnits =  { _ in shuffled }
            }
        )
        await store.send(.tools(.shuffle)) {
            $0.lists.study = .init(
                units: shuffled,
                frontType: $0.setting.frontType,
                isLocked: false
            )
            $0.lists.clear()
        }
    }
    
    func test_tools_setting() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        
        for _ in 0..<Random.int(from: 1, to: 10) {
            await store.send(.tools(.setting)) {
                $0.showSideBar.toggle()
            }
        }
    }
    
    func test_modals_unitEdited() async {
        let units: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: StudyUnits.State(
                units: units
            ),
            reducer: { StudyUnits() }
        )
        let toEdit = units.randomElement()!
        let edited = StudyUnit(
            id: toEdit.id,
            kanjiText: Random.string,
            meaningText: Random.string,
            studyState: toEdit.studyState,
            studySets: toEdit.studySets
        )
        await store.send(.modals(.unitEdited(edited))) {
            $0.lists.updateUnit(edited)
            $0.setting.listType = .study
        }
    }
    
    func test_setting_setFilter() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        let filter = UnitFilter
            .allCases
            .filter { store.state.lists.study.filter != $0 }
            .randomElement()!
        await store.send(.setting(.setFilter(filter))) {
            $0.setting.filter = filter
            $0.lists.setFilter(filter)
        }
        await store.receive(.showSideBar(false))
    }
    
    func test_setting_setFrontType() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        let frontType: FrontType = .allCases
            .filter { store.state.setting.frontType != $0 }
            .randomElement()!
        await store.send(.setting(.setFrontType(frontType))) {
            $0.setting.frontType = frontType
            $0.lists.setFrontType(frontType)
        }
        await store.receive(.showSideBar(false))
    }
    
    func test_setting_setListType() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        let listType: ListType = store.state.setting.selectableListType
            .filter { store.state.setting.listType != $0 }
            .randomElement()!
        await store.send(.setting(.setListType(listType))) {
            $0.setting.listType = listType
            $0.lists.setListType(listType)
        }
        await store.receive(.showSideBar(false))
    }
    
}

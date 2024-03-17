//
//  StudyUnitsTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/22/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class StudyUnitsTest: XCTestCase {
    
    @MainActor
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
    
    @MainActor
    func test_showSideBar() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        
        XCTAssertEqual(store.state.showSideBar, false)

        await store.send(.showSideBar(true)) {
            $0.showSideBar = true
        }
    }
    
    @MainActor
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
    
    @MainActor
    func test_tools_setting() async {
        let store = TestStore(
            initialState: StudyUnits.State(
                units: .testMock
            ),
            reducer: { StudyUnits() }
        )
        
        await store.send(.tools(.setting)) {
            $0.showSideBar.toggle()
        }
    }
    
    @MainActor
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
    
    @MainActor
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
            $0.showSideBar = false
        }
    }
    
    @MainActor
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
            $0.showSideBar = false
        }
    }
    
    @MainActor
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
            $0.showSideBar = false
        }
    }
    
}

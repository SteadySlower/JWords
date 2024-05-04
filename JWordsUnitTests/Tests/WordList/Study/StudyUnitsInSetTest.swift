//
//  StudyUnitsInSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords
import Huri

final class StudyUnitsInSetTest: XCTestCase {
    
    @MainActor
    func test_lists_toEditUnitSelected() async {
        let convertedKanjiText = Random.string
        let huris: [Huri] = .testMock
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() },
            withDependencies: {
                $0.huriganaClient.huriToKanjiText = { _ in convertedKanjiText }
                $0.huriganaClient.convertToHuris = { _ in huris }
            }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(\.lists.toEditUnitSelected, unit) {
            $0.modals.setEditUnitModal(unit: unit, convertedKanjiText: convertedKanjiText, huris: huris)
        }
    }
    
    @MainActor
    func test_showSideBar() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        XCTAssertEqual(store.state.showSideBar, false)
        
        await store.send(.showSideBar(true)) {
            $0.showSideBar = true
        }
    }
    
    @MainActor
    func test_tools_set_selected_notNil() async {
        var selectUnits = IdentifiedArray(uniqueElements: [StudyUnit].testMock.map { SelectUnit.State(unit: $0, isSelected: true)  })
        let unselected = IdentifiedArray(uniqueElements: [StudyUnit].testMock.map { SelectUnit.State(unit: $0, isSelected: false)  })
        selectUnits.append(contentsOf: unselected)
        
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                lists: .init(
                    study: .init(
                        units: .testMock,
                        frontType: .allCases.randomElement()!,
                        isLocked: .random()
                    ),
                    select: .init(
                        idArray: selectUnits
                    )
                )
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        await store.send(\.tools.set) {
            $0.modals.setMoveUnitModal(
                from: $0.set,
                isReview: false,
                toMove: $0.lists.selectedUnits!
            )
        }
    }
    
    @MainActor
    func test_tools_set_selected_nil() async {
        let isReviewSet: Bool = .random()
        let set: StudySet = .testMock
        let units: [StudyUnit] = .testMock
        
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: set,
                units: units
            ),
            reducer: { StudyUnitsInSet() },
            withDependencies: {
                $0.scheduleClient.isReview = { _ in isReviewSet }
            }
        )
        
        await store.send(\.tools.set) {
            $0.modals.setMoveUnitModal(
                from: set,
                isReview: isReviewSet,
                toMove: units.filter { $0.studyState != .success }
            )
        }
    }
    
    @MainActor
    func test_tools_shuffle() async {
        let shuffled: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() },
            withDependencies: {
                $0.utilClient.shuffleUnits =  { _ in shuffled }
            }
        )
        
        await store.send(\.tools.shuffle) {
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
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        await store.send(\.tools.setting) {
            $0.showSideBar.toggle()
        }
    }
    
    @MainActor
    func test_modals_setEdited() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        let set: StudySet = .testMock
        await store.send(\.modals.setEdited, set) {
            $0.set = set
        }
    }
    
    @MainActor
    func test_modals_unitAdded() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(\.modals.unitAdded, unit) {
            $0.lists.addNewUnit(unit)
        }
    }
    
    @MainActor
    func test_modals_unitEdited() async {
        let units: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: units
            ),
            reducer: { StudyUnitsInSet() }
        )
        let toEdit = units.randomElement()!
        let edited = StudyUnit(
            id: toEdit.id,
            kanjiText: Random.string,
            meaningText: Random.string,
            studyState: toEdit.studyState,
            studySets: toEdit.studySets
        )
        await store.send(\.modals.unitEdited, edited) {
            $0.lists.updateUnit(edited)
            $0.setting.listType = .study
        }
    }
    
    @MainActor
    func test_setting_setEditButtonTapped() async {
        let set: StudySet = .testMock
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: set,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        await store.send(\.setting.setEditButtonTapped) {
            $0.modals.setEditSetModal(set)
            $0.showSideBar = false
        }
    }

    @MainActor
    func test_setting_unitAddButtonTapped() async {
        let set: StudySet = .testMock
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: set,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        await store.send(\.setting.unitAddButtonTapped) {
            $0.modals.setAddUnitModal(set)
            $0.showSideBar = false
        }
    }
    
    @MainActor
    func test_setting_setFilter() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        let filter = UnitFilter
            .allCases
            .filter { store.state.lists.study.filter != $0 }
            .randomElement()!
        await store.send(\.setting.setFilter, filter) {
            $0.setting.filter = filter
            $0.lists.setFilter(filter)
            $0.showSideBar = false
        }
    }
    
    @MainActor
    func test_setting_setFrontType() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        let frontType: FrontType = .allCases
            .filter { store.state.setting.frontType != $0 }
            .randomElement()!
        await store.send(\.setting.setFrontType, frontType) {
            $0.setting.frontType = frontType
            $0.lists.setFrontType(frontType)
            $0.showSideBar = false
        }
    }
    
    @MainActor
    func test_setting_setListType() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        let listType: ListType = store.state.setting.selectableListType
            .filter { store.state.setting.listType != $0 }
            .randomElement()!
        await store.send(\.setting.setListType, listType) {
            $0.setting.listType = listType
            $0.lists.setListType(listType)
            $0.showSideBar = false
        }
    }
    
}

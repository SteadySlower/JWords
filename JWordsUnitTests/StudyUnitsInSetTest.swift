//
//  StudyUnitsInSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class StudyUnitsInSetTest: XCTestCase {
    
    func test_lists_toEditUnitSelected() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(.lists(.toEditUnitSelected(unit))) {
            $0.modals.setEditUnitModal(unit)
        }
    }
    
    func test_showSideBar() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        var showSideBar = store.state.showSideBar
        
        for _ in 0..<Random.int(from: 1, to: 100) {
            showSideBar.toggle()
            await store.send(.showSideBar(showSideBar)) {
                $0.showSideBar = showSideBar
            }
        }
    }
    
    func test_tools_set_selectedNotNil() async {
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
        
        await store.send(.tools(.set)) {
            $0.modals.setMoveUnitModal(
                from: $0.set,
                isReview: false,
                toMove: $0.lists.selectedUnits!
            )
        }
    }
    
    func test_tools_set_selectedNil() async {
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
        
        await store.send(.tools(.set)) {
            $0.modals.setMoveUnitModal(
                from: set,
                isReview: isReviewSet,
                toMove: units.filter { $0.studyState != .success }
            )
        }
    }
    
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
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        for _ in 0..<Random.int(from: 1, to: 10) {
            await store.send(.tools(.setting)) {
                $0.showSideBar.toggle()
            }
        }
    }
    
    func test_modals_setEdited() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        let set: StudySet = .testMock
        await store.send(.modals(.setEdited(set))) {
            $0.set = set
        }
    }
    
    func test_modals_unitAdded() async {
        let store = TestStore(
            initialState: StudyUnitsInSet.State(
                set: .testMock,
                units: .testMock
            ),
            reducer: { StudyUnitsInSet() }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(.modals(.unitAdded(unit))) {
            $0.lists.addNewUnit(unit)
        }
    }
    
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
        await store.send(.modals(.unitEdited(edited))) {
            $0.lists.updateUnit(edited)
            $0.setting.listType = .study
        }
    }
    
}

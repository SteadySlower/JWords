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
    
}

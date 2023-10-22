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
    
}

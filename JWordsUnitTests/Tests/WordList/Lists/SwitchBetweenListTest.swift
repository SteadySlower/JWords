//
//  SwitchBetweenListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class SwitchBetweenListTest: XCTestCase {
    
    @MainActor
    func test_edit_toEditUnitSelected() async {
        let units: [StudyUnit] = .testMock
        let frontType: FrontType = .allCases.randomElement()!
        
        let store = TestStore(
            initialState: SwitchBetweenList.State(
                study: .init(
                    units: units,
                    frontType: frontType,
                    isLocked: .random()
                ),
                edit: .init(
                    units: units,
                    frontType: frontType
                )
            ),
            reducer: { SwitchBetweenList() }
        )
        
        let unit: StudyUnit = .testMock
        
        await store.send(\.edit.toEditUnitSelected, unit)
        await store.receive(.toEditUnitSelected(unit))
    }
    
}


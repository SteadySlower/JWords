//
//  SwitchBetweenListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class SwitchBetweenListTest: XCTestCase {
    
    func test_edit_toEditUnitSelected() async {
        let store = TestStore(
            initialState: SwitchBetweenList.State(
                units: .testMock,
                frontType: .allCases.randomElement()!,
                isLocked: Bool.random()
            ),
            reducer: { SwitchBetweenList() }
        )
        
        let unit: StudyUnit = .testMock
        
        await store.send(.edit(.toEditUnitSelected(unit)))
        await store.receive(.toEditUnitSelected(unit))
    }
    
}

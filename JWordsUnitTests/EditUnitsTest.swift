//
//  EditUnitsTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class EditUnitsTest: XCTestCase {
    
    @MainActor
    func test_unit_element_cellTapped() async {
        let store = TestStore(
            initialState: EditUnits.State(
                units: .testMock,
                frontType: .allCases.randomElement()!
            ),
            reducer: { EditUnits() }
        )
        
        let unit = store.state.units.randomElement()!.unit
        
        await store.send(.unit(.element(id: unit.id, action: .cellTapped(unit))))
        await store.receive(.toEditUnitSelected(unit))
    }
    
}

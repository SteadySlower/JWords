//
//  SelectUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class SelectUnitTest: XCTestCase {
    
    @MainActor
    func test_toggleSelection() async {
        let store = TestStore(
            initialState: SelectUnit.State(unit: .testMock),
            reducer: { SelectUnit() }
        )
        
        XCTAssertEqual(store.state.isSelected, false)
        
        await store.send(.toggleSelection) {
            $0.isSelected.toggle()
        }
    }
    
}

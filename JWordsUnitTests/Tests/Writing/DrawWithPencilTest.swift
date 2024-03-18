//
//  DrawWithPencilTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class DrawWithPencilTest: XCTestCase {

    @MainActor
    func test_resetCanvas() async {
        let store = TestStore(
            initialState: DrawWithPencil.State(
                didDraw: true
            ),
            reducer: { DrawWithPencil() }
        )
        
        await store.send(.resetCanvas) {
            $0.didDraw = false
        }
    }
    
    @MainActor
    func test_setDidDraw() async {
        let store = TestStore(
            initialState: DrawWithPencil.State(),
            reducer: { DrawWithPencil() }
        )
        
        XCTAssertEqual(store.state.didDraw, false)
        
        await store.send(.setDidDraw(true)) {
            $0.didDraw = true
        }
    }
    
}

//
//  InputSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class InputSetTest: XCTestCase {
    
    func test_updateTitle() async {
        let store = TestStore(
            initialState: InputSet.State(),
            reducer: { InputSet() }
        )
        
        let text = Random.string
        
        await store.send(.updateTitle(text)) {
            $0.title = text
        }
    }
    
}

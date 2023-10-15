//
//  MeaningInputTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class MeaningInputTest: XCTestCase {
    
    func testUpdateText() async {
        let store = TestStore(
            initialState: MeaningInput.State(),
            reducer: { MeaningInput() }
        )
        
        let text = Random.string
        
        await store.send(.updateText(text)) {
            $0.text = text
        }
    }
    
}


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
    
    func testUpdateTextHasTab() async {
        let store = TestStore(
            initialState: MeaningInput.State(),
            reducer: { MeaningInput() }
        )
        
        let textWithTab = [
            "\t",
            "\t" + Random.string,
            Random.string + "\t",
            Random.string + "\t" + Random.string,
        ].randomElement()!
        
        await store.send(.updateText(textWithTab))
        await store.receive(.onTab)
    }
    
}


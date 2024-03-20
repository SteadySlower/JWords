//
//  MeaningInputTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class MeaningInputTest: XCTestCase {
    
    @MainActor
    func test_setText() async {
        let store = TestStore(
            initialState: MeaningInput.State(),
            reducer: { MeaningInput() }
        )
        
        let text = Random.string
        
        await store.send(.setText(text)) {
            $0.text = text
        }
    }
    
    @MainActor
    func test_setText_hasTab() async {
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
        
        await store.send(.setText(textWithTab))
        await store.receive(.onTab)
    }
    
}


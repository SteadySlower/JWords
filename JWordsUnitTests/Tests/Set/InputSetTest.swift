//
//  InputSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class InputSetTest: XCTestCase {
    
    @MainActor
    func test_setTitle() async {
        let store = TestStore(
            initialState: InputSet.State(),
            reducer: { InputSet() }
        )
        
        let text = Random.string
        
        await store.send(.setTitle(text)) {
            $0.title = text
        }
    }
    
    @MainActor
    func test_setFrontType() async {
        let types: [FrontType] = [.kanji, .meaning].shuffled()
        let type1 = types[0]
        let type2 = types[1]
        
        let store = TestStore(
            initialState: InputSet.State(
                frontType: type1
            ),
            reducer: { InputSet() }
        )
        
        await store.send(.setFrontType(type2)) {
            $0.frontType = type2
        }
    }
    
}

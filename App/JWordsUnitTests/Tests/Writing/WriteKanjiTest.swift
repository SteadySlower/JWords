//
//  WriteKanjiTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class WriteKanjiTest: XCTestCase {
    
    @MainActor
    func test_toggleShowAnswer() async {
        let store = TestStore(
            initialState: WriteKanji.State(),
            reducer: { WriteKanji() }
        )
        
        XCTAssertEqual(store.state.showAnswer, false)
        
        await store.send(.toggleShowAnswer) {
            $0.showAnswer.toggle()
        }
    }
    
}

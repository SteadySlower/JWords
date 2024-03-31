//
//  DisplayWritingKanjiTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class DisplayWritingKanjiTest: XCTestCase {
    
    @MainActor
    func test_updateStudyState() async {
        let kanji: Kanji = .testMock
        let beforeState = kanji.studyState
        let newState = StudyState.allCases.filter { $0 != beforeState }.randomElement()!
        let store = TestStore(
            initialState: DisplayWritingKanji.State(kanji: .testMock),
            reducer: { DisplayWritingKanji() },
            withDependencies: {
                $0.writingKanjiClient.studyState = { _, _ in newState }
            }
        )
        await store.send(.updateStudyState(newState)) {
            $0.studyState = newState
        }
    }
    
}

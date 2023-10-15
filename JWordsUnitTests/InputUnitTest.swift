//
//  InputUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class InputUnitTest: XCTestCase {
    
    func testKanjiInputHuriganaUpdatedAlreadyExist() async {
        let alreadyExist: StudyUnit = .testMock
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() },
            withDependencies: {
                $0.studyUnitClient.checkIfExist = { _ in alreadyExist }
            }
        )
        
        await store.send(.kanjiInput(.huriganaUpdated(Random.string)))
        await store.receive(.alreadyExist(alreadyExist))
    }
    
    func testKanjiInputHuriganaUpdatedAlreadyExistNil() async {
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() },
            withDependencies: {
                $0.studyUnitClient.checkIfExist = { _ in nil }
            }
        )
        
        await store.send(.kanjiInput(.huriganaUpdated(Random.string)))
        await store.receive(.alreadyExist(nil))
    }
    
}

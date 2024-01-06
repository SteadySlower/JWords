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
    
    func test_kanjiInput_HuriganaUpdated_alreadyExist() async {
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
    
    func test_kanjiInput_huriganaUpdated_alreadyExist_nçil() async {
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
    
    func test_kanjiInput_onTab() async {
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() }
        )
        
        await store.send(.kanjiInput(.onTab)) {
            $0.kanjiInput.isEditing = false
            $0.focusedField = .meaning
        }
    }
    
    func test_meaningInput_onTab() async {
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() }
        )
        
        await store.send(.meaningInput(.onTab)) {
            $0.focusedField = .kanji
        }
    }
    
}

//
//  InputUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords
import Huri

final class InputUnitTest: XCTestCase {
    
    @MainActor
    func test_kanjiInput_huriganaUpdated_alreadyExist() async {
        let alreadyExist: StudyUnit = .testMock
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() },
            withDependencies: {
                $0.studyUnitClient.checkIfExist = { _ in alreadyExist }
            }
        )
        
        await store.send(\.kanjiInput.huriganaUpdated, Random.string)
        await store.receive(.alreadyExist(alreadyExist))
    }
    
    @MainActor
    func test_kanjiInput_huriganaUpdated_alreadyExist_nil() async {
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() },
            withDependencies: {
                $0.studyUnitClient.checkIfExist = { _ in nil }
            }
        )
        
        await store.send(\.kanjiInput.huriganaUpdated, Random.string)
        await store.receive(.alreadyExist(nil))
    }
    
    @MainActor
    func test_kanjiInput_onTab_alreadyExist() async {
        let alreadyExist: StudyUnit = .testMock
        let converted = Random.string
        let huris: [Huri] = .testMock
        let store = TestStore(
            initialState: InputUnit.State(
                kanjiInput: .init(text: Random.string)
            ),
            reducer: { InputUnit() },
            withDependencies: {
                $0.studyUnitClient.checkIfExist = { _ in alreadyExist }
                $0.huriganaClient.convert = { _ in converted }
                $0.huriganaClient.convertToHuris = { _ in huris }
            }
        )
        
        await store.send(\.kanjiInput.onTab) {
            $0.kanjiInput.huris = huris
            $0.kanjiInput.isEditing = false
            $0.focusedField = .meaning
        }
        
        await store.receive(.alreadyExist(alreadyExist))
    }
    
    @MainActor
    func test_kanjiInput_onTab_alreadyExist_nil() async {
        let converted = Random.string
        let huris: [Huri] = .testMock
        let store = TestStore(
            initialState: InputUnit.State(
                kanjiInput: .init(text: Random.string)
            ),
            reducer: { InputUnit() },
            withDependencies: {
                $0.studyUnitClient.checkIfExist = { _ in nil }
                $0.huriganaClient.convert = { _ in converted }
                $0.huriganaClient.convertToHuris = { _ in huris }
            }
        )
        
        await store.send(\.kanjiInput.onTab) {
            $0.kanjiInput.huris = huris
            $0.kanjiInput.isEditing = false
            $0.focusedField = .meaning
        }
        
        await store.receive(.alreadyExist(nil))
    }
    
    @MainActor
    func test_meaningInput_onTab() async {
        let store = TestStore(
            initialState: InputUnit.State(),
            reducer: { InputUnit() }
        )
        
        await store.send(\.meaningInput.onTab) {
            $0.focusedField = .kanji
        }
    }
}

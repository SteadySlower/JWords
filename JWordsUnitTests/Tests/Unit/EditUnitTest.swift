//
//  EditUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords
import HuriConverter

final class EditUnitTest: XCTestCase {
    
    @MainActor
    func test_init() async {
        let unit: StudyUnit = .testMock
        let convertedKanjiText = Random.string
        let huris: [Huri] = .testMock
        let store = TestStore(
            initialState: EditUnit.State(
                unit: unit,
                convertedKanjiText: convertedKanjiText,
                huris: huris
            ),
            reducer: { EditUnit() }
        )
        
        XCTAssert(store.state.unit == unit)
        XCTAssert(store.state.inputUnit.kanjiInput.text == convertedKanjiText)
        XCTAssert(store.state.inputUnit.kanjiInput.huris == huris)
        XCTAssert(store.state.inputUnit.kanjiInput.isEditing == false)
        XCTAssert(store.state.inputUnit.meaningInput.text == unit.meaningText)
    }
    
    @MainActor
    func test_inputUnit_alreadyExist_nil() async {
        let store = TestStore(
            initialState: EditUnit.State(
                unit: .testMock,
                convertedKanjiText: Random.string,
                huris: .testMock
            ),
            reducer: { EditUnit() }
        )
        
        await store.send(\.inputUnit.alreadyExist, nil)
    }
    
    @MainActor
    func test_inputUnit_alreadyExist_with_same_id() async {
        let id = Random.string
        let unit: StudyUnit = .init(
            id: id,
            kanjiText: Random.string,
            meaningText: Random.string,
            studyState: Random.studyState,
            studySets: .testMock)
        let alreadyExist: StudyUnit = .init(
            id: id,
            kanjiText: Random.string,
            meaningText: Random.string,
            studyState: Random.studyState,
            studySets: .testMock)
        let store = TestStore(
            initialState: EditUnit.State(
                unit: unit,
                convertedKanjiText: Random.string,
                huris: .testMock
            ),
            reducer: { EditUnit() }
        )
        
        await store.send(\.inputUnit.alreadyExist, alreadyExist)
    }
    
    @MainActor
    func test_inputUnit_alreadyExist_with_different_id() async {
        let unit: StudyUnit = .testMock
        let alreadyExist: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: EditUnit.State(
                unit: unit,
                convertedKanjiText: Random.string,
                huris: .testMock
            ),
            reducer: { EditUnit() }
        )
        
        await store.send(\.inputUnit.alreadyExist, alreadyExist) {
            $0.setUneditableAlert()
        }
    }
    
    @MainActor
    func test_edit() async {
        let edited: StudyUnit = .testMock
        let store = TestStore(
            initialState: EditUnit.State(
                unit: .testMock,
                convertedKanjiText: Random.string,
                huris: .testMock
            ),
            reducer: { EditUnit() },
            withDependencies: {
                $0.studyUnitClient.edit = { _, _ in edited }
                $0.huriganaClient.hurisToHurigana = { _ in Random.string }
            })
        await store.send(.edit)
        await store.receive(.edited(edited))
    }
    
    @MainActor
    func test_alert_presented_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let unit: StudyUnit = .testMock
        let alreadyExist: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: EditUnit.State(
                unit: unit,
                convertedKanjiText: Random.string,
                huris: .testMock
            ),
            reducer: { EditUnit() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(\.inputUnit.alreadyExist, alreadyExist) {
            $0.setUneditableAlert()
        }
        
        await store.send(\.alert.cancel) {
            $0.alert = nil
        }
        
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        
        let store = TestStore(
            initialState: EditUnit.State(
                unit: .testMock,
                convertedKanjiText: Random.string,
                huris: .testMock
            ),
            reducer: { EditUnit() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
}

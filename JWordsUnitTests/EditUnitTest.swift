//
//  EditUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class EditUnitTest: XCTestCase {
    
    func testInit() async {
        let unit: StudyUnit = .testMock
        let store = TestStore(
            initialState: EditUnit.State(unit: unit),
            reducer: { EditUnit() }
        )
        
        XCTAssert(store.state.unit == unit)
        XCTAssert(store.state.inputUnit.kanjiInput.text == HuriganaConverter.shared.huriToKanjiText(from: unit.kanjiText))
        XCTAssert(store.state.inputUnit.kanjiInput.hurigana.hurigana == EditHuriganaText.State(hurigana: unit.kanjiText).hurigana)
        XCTAssert(store.state.inputUnit.kanjiInput.isEditing == false)
        XCTAssert(store.state.inputUnit.meaningInput.text == unit.meaningText)
    }
    
    func testInputUnitAlreadyExistNil() async {
        let store = TestStore(
            initialState: EditUnit.State(unit: .testMock),
            reducer: { EditUnit() }
        )
        
        await store.send(.inputUnit(.alreadyExist(nil)))
    }
    
    func testInputUnitAlreadyExistSameKanjiText() async {
        let kanjiText = Random.string
        let unit: StudyUnit = .init(
            kanjiText: kanjiText,
            meaningText: Random.string,
            studyState: [.undefined, .success, .fail].randomElement()!,
            studySets: .testMock)
        let alreadyExist: StudyUnit = .init(
            kanjiText: kanjiText,
            meaningText: Random.string,
            studyState: [.undefined, .success, .fail].randomElement()!,
            studySets: .testMock)
        let store = TestStore(
            initialState: EditUnit.State(unit: unit),
            reducer: { EditUnit() }
        )
        
        await store.send(.inputUnit(.alreadyExist(alreadyExist)))
    }
    
    func testInputUnitAlreadyExistDifferentKanjiText() async {
        let unit: StudyUnit = .testMock
        let alreadyExist: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: EditUnit.State(unit: unit),
            reducer: { EditUnit() }
        )
        
        await store.send(.inputUnit(.alreadyExist(alreadyExist))) {
            $0.setUneditableAlert()
        }
    }
    
    func testEdit() async {
        let unit: StudyUnit = .testMock
        let edited: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: EditUnit.State(
                unit: unit)
        ) {
            EditUnit()
        } withDependencies: {
            $0.studyUnitClient.edit = { _, _ in edited }
        }

        await store.send(.edit)
        
        await store.receive(.edited(edited))
    }
    
}

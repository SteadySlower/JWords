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
    
}

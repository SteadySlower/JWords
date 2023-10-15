//
//  AddUnitWithOCRTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class AddUnitWithOCRTest: XCTestCase {
    
    func test_ocr_koreanOCR() async {
        let store = TestStore(
            initialState: AddUnitWithOCR.State(),
            reducer: { AddUnitWithOCR() }
        )
        
        let ocr = Random.string
        
        await store.send(.ocr(.koreanOCR(ocr))) {
            $0.addUnit.inputUnit.meaningInput.text = ocr
        }
    }
    
    func test_ocr_japaneseOCR_emptyKanjiInput() async {
        let store = TestStore(
            initialState: AddUnitWithOCR.State(),
            reducer: { AddUnitWithOCR() }
        )
        
        let ocr = Random.string
        
        await store.send(.ocr(.japaneseOCR(ocr))) {
            $0.addUnit.inputUnit.kanjiInput.text = ocr
        }
    }
    
    func test_ocr_japaneseOCR_withKanjiInput() async {
        let store = TestStore(
            initialState: AddUnitWithOCR.State(
                addUnit: .init(
                    inputUnit: .init(
                        kanjiInput: .init(
                            text: Random.string,
                            hurigana: .init(hurigana: Random.string),
                            isEditing: false
                        )
                    )
                )
            ),
            reducer: { AddUnitWithOCR() }
        )
        
        let ocr = Random.string
        
        await store.send(.ocr(.japaneseOCR(ocr))) {
            $0.addUnit.inputUnit.kanjiInput.text = ocr
            $0.addUnit.inputUnit.kanjiInput.hurigana = .init(hurigana: "")
            $0.addUnit.inputUnit.kanjiInput.isEditing = true
        }
    }
    
}

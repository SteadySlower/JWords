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
    
}

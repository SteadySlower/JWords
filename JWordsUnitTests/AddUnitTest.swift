//
//  AddUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/14.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class AddUnitTest: XCTestCase {
    
    func testInputUnitAlreadyExist() async {
        let store = TestStore(
            initialState: AddUnit.State(),
            reducer: { AddUnit() }
        )
        
        let unit: StudyUnit = .testMock
        
        await store.send(.inputUnit(.alreadyExist(unit))) {
            $0.alreadyExist = unit
            $0.setExistAlert()
        }
    }
    
}


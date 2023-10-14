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
    
    func testAddNoSet() async {
        let store = TestStore(
            initialState: AddUnit.State(),
            reducer: { AddUnit() }
        )
        
        await store.send(.add) {
            $0.setNoSetAlert()
        }
    }
    
    func testAddAlreadyExist() async {
        let inserted: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: AddUnit.State(
                set: .testMock,
                alreadyExist: .testMock
            )
        ) {
            AddUnit()
        } withDependencies: {
            $0.studyUnitClient.edit = { _, _ in .testMock }
            $0.studyUnitClient.insertExisting = { _, _ in inserted }
        }

        await store.send(.add)
        
        await store.receive(.added(inserted))
    }
    
}


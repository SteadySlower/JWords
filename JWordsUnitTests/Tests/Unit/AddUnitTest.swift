//
//  AddUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/14.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class AddUnitTest: XCTestCase {
    
    @MainActor
    func test_inputUnit_alreadyExist() async {
        let store = TestStore(
            initialState: AddUnit.State(),
            reducer: { AddUnit() }
        )
        
        let unit: StudyUnit = .testMock
        
        await store.send(\.inputUnit.alreadyExist, unit) {
            $0.alreadyExist = unit
            $0.inputUnit.meaningInput.text = unit.meaningText
            $0.setExistAlert()
        }
    }
    
    @MainActor
    func test_add_no_set() async {
        let store = TestStore(
            initialState: AddUnit.State(),
            reducer: { AddUnit() }
        )
        
        await store.send(.add) {
            $0.setNoSetAlert()
        }
    }
    
    @MainActor
    func test_add_alreadyExist() async {
        let inserted: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: AddUnit.State(set: .testMock, alreadyExist: .testMock)
        ) {
            AddUnit()
        } withDependencies: {
            $0.studyUnitClient.edit = { _, _ in .testMock }
            $0.studyUnitClient.insertExisting = { _, _ in inserted }
        }

        await store.send(.add)
        await store.receive(.added(inserted))
    }
    
    @MainActor
    func test_add_not_alreadyExist() async {
        let inserted: StudyUnit = .testMock
        
        let store = TestStore(
            initialState: AddUnit.State(set: .testMock)
        ) {
            AddUnit()
        } withDependencies: {
            $0.studyUnitClient.insert = { _, _ in inserted }
        }

        await store.send(.add)
        await store.receive(.added(inserted))
    }
    
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: AddUnit.State(),
            reducer: { AddUnit() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}


//
//  MoveUnitsTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class MoveUnitsTest: XCTestCase {
    
    func test_onAppear() async {
        
        let sets: [StudySet] = .testMock
        
        let store = TestStore(
            initialState: MoveUnits.State(
                fromSet: .testMock,
                isReviewSet: Bool.random(),
                toMoveUnits: .testMock
            ),
            reducer: { MoveUnits() },
            withDependencies: {
                $0.studySetClient.fetch = { _ in sets }
            }
        )
        
        await store.send(.onAppear) {
            $0.sets = sets
        }
    }
    
    func test_updateSelection() async {
        let store = TestStore(
            initialState: MoveUnits.State(
                fromSet: .testMock,
                isReviewSet: Bool.random(),
                toMoveUnits: .testMock
            ),
            reducer: { MoveUnits() }
        )
        
        store.assert {
            $0.selectedID = nil
        }
        
        let id = Random.string
        
        await store.send(.updateSelection(id)) {
            $0.selectedID = id
        }
    }
    
}

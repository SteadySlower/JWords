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
                toMoveUnits: .testMock,
                willCloseSet: Bool.random()
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
                toMoveUnits: .testMock,
                willCloseSet: Bool.random()
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
    
    func test_updateWillClose() async {
        var willClose = Bool.random()
        
        let store = TestStore(
            initialState: MoveUnits.State(
                fromSet: .testMock,
                isReviewSet: Bool.random(),
                toMoveUnits: .testMock,
                willCloseSet: willClose
            ),
            reducer: { MoveUnits() }
        )
        
        willClose.toggle()
        
        await store.send(.updateWillClose(willClose)) {
            $0.willCloseSet = willClose
        }
    }
    
    func test_closeButtonTapped() async {
        let selectedID = [nil, Random.string].randomElement()!
        
        let store = TestStore(
            initialState: MoveUnits.State(
                fromSet: .testMock,
                selectedID: selectedID,
                isReviewSet: Bool.random(),
                toMoveUnits: .testMock,
                willCloseSet: Bool.random()
            ),
            reducer: { MoveUnits() },
            withDependencies: {
                $0.studyUnitClient.move = { _, _, _ in  }
                $0.studySetClient.close = { _ in  }
                $0.scheduleClient.reviewed = { _ in  }
            }
        )
        
        await store.send(.closeButtonTapped)
        await store.receive(.onMoved)
    }
    
}

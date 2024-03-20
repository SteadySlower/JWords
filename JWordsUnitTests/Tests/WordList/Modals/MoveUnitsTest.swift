//
//  MoveUnitsTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class MoveUnitsTest: XCTestCase {
    
    @MainActor
    func test_fetchSets() async {
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
        
        await store.send(.fetchSets) {
            $0.sets = sets
        }
    }
    
    @MainActor
    func test_setSelectedID() async {
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
        await store.send(.setSelectedID(id)) {
            $0.selectedID = id
        }
    }
    
    @MainActor
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
        await store.send(.setWillClose(willClose)) {
            $0.willCloseSet = willClose
        }
    }
    
    @MainActor
    func test_close() async {
        let invokedFunctions: LockIsolated<[String]> = .init([])
        let sets: [StudySet] = .testMock
        let selectedID = ([nil] + sets).randomElement()!?.id
        let isReviewSet = Bool.random()
        let willCloseSet = Bool.random()
        
        let store = TestStore(
            initialState: MoveUnits.State(
                fromSet: .testMock,
                selectedID: selectedID,
                isReviewSet: isReviewSet,
                toMoveUnits: .testMock,
                willCloseSet: willCloseSet,
                sets: sets
            ),
            reducer: { MoveUnits() },
            withDependencies: {
                $0.studyUnitClient.move = { _, _, _ in invokedFunctions.withValue { $0.append("move") } }
                $0.studySetClient.close = { _ in invokedFunctions.withValue { $0.append("close") } }
                $0.scheduleClient.reviewed = { _ in invokedFunctions.withValue { $0.append("reviewed") } }
            }
        )
        
        await store.send(.close)
        await store.receive(.onMoved)
        
        if selectedID != nil {
            XCTAssertEqual(invokedFunctions.value.contains("move"), true)
        }
        
        if willCloseSet {
            XCTAssertEqual(invokedFunctions.value.contains("close"), true)
        }
        
        if isReviewSet {
            XCTAssertEqual(invokedFunctions.value.contains("reviewed"), true)
        }
    }
    
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: MoveUnits.State(
                fromSet: .testMock,
                isReviewSet: Bool.random(),
                toMoveUnits: .testMock,
                willCloseSet: Bool.random()
            ),
            reducer: { MoveUnits() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}

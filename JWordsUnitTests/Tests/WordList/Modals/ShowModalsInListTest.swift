//
//  ShowModalsInListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class ShowModalsInListTest: XCTestCase {
    
    @MainActor
    func test_destination_presented_editSet_edited() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                destination: .editSet(.init(.testMock))
            ),
            reducer: { ShowModalsInList() }
        )
        let set: StudySet = .testMock
        await store.send(\.destination.editSet.edited, set) {
            $0.destination = nil
        }
        await store.receive(.setEdited(set))
    }
    
    @MainActor
    func test_destination_presented_addUnit_added() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                destination: .addUnit(.init())
            ),
            reducer: { ShowModalsInList() }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(\.destination.addUnit.added, unit) {
            $0.destination = nil
        }
        await store.receive(.unitAdded(unit))
    }
    
    @MainActor
    func test_destination_presented_editUnit_edited() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                destination: .editUnit(.init(unit: .testMock))
            ),
            reducer: { ShowModalsInList() }
        )
        
        let unit: StudyUnit = .testMock
        await store.send(\.destination.editUnit.edited, unit) {
            $0.destination = nil
        }
        await store.receive(.unitEdited(unit))
    }
    
    @MainActor
    func test_destination_presented_moveUnits_onMoved() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                destination: .moveUnits(.init(
                    fromSet: .testMock,
                    isReviewSet: Random.bool,
                    toMoveUnits: .testMock,
                    willCloseSet: Random.bool)
                )
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(\.destination.moveUnits.onMoved) {
            $0.destination = nil
        }
        await store.receive(.unitsMoved)
    }
    
}

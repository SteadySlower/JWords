//
//  ShowModalsInListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class ShowModalsInListTest: XCTestCase {
    
    func test_showEditSetModal_true() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showEditUnitModal(true))
    }
    
    func test_showEditSetModal_false() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                editSet: .init(.testMock)
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showEditSetModal(false)) {
            $0.editSet = nil
        }
    }
    
    func test_showAddUnitModal_true() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showAddUnitModal(true))
    }
    
    func test_showAddUnitModal_false() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                addUnit: .init()
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showAddUnitModal(false)) {
            $0.addUnit = nil
        }
    }
    
    func test_showEditUnitModal_true() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showEditUnitModal(true))
    }
    
    func test_showEditUnitModal_false() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                editUnit: .init(unit: .testMock)
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showEditUnitModal(false)) {
            $0.editUnit = nil
        }
    }
    
    func test_showMoveUnitsModal_true() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showMoveUnitsModal(true))
    }
    
    func test_showMoveUnitsModal_false() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                moveUnits: .init(
                    fromSet: .testMock,
                    isReviewSet: Bool.random(),
                    toMoveUnits: .testMock,
                    willCloseSet: Bool.random()
                )
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showMoveUnitsModal(false)) {
            $0.moveUnits = nil
        }
    }
    
    func test_editSet_edited() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                editSet: .init(.testMock)
            ),
            reducer: { ShowModalsInList() }
        )
        
        let set: StudySet = .testMock
        
        await store.send(.editSet(.edited(set))) {
            $0.editSet = nil
        }
        
        await store.receive(.setEdited(set))
    }
    
    func test_editSet_cancel() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                editSet: .init(.testMock)
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.editSet(.cancel)) {
            $0.editSet = nil
        }
    }
    
    func test_addUnit_added() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                addUnit: .init()
            ),
            reducer: { ShowModalsInList() }
        )
        
        let unit: StudyUnit = .testMock
        
        await store.send(.addUnit(.added(unit))) {
            $0.addUnit = nil
        }
        
        await store.receive(.unitAdded(unit))
    }
    
    func test_addUnit_cancel() async {
        let store = TestStore(
            initialState: ShowModalsInList.State(
                addUnit: .init()
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.addUnit(.cancel)) {
            $0.addUnit = nil
        }
    }
    
}

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
        let editSet = EditSet.State(.testMock)
        let store = TestStore(
            initialState: ShowModalsInList.State(
                editSet: editSet
            ),
            reducer: { ShowModalsInList() }
        )
        
        await store.send(.showEditSetModal(false)) {
            $0.editSet = nil
        }
    }
    
}

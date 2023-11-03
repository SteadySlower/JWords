//
//  SelectionStudySetTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 11/2/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class SelectionStudySetTest: XCTestCase {
    
    func testOnAppear() async {
        let sets: [StudySet] = .testMock
        let store = TestStore(
            initialState: SelectStudySet.State(),
            reducer: { SelectStudySet() },
            withDependencies: {
                $0.studySetClient.fetch = { _ in sets }
            }
        )
        
        await store.send(.onAppear) {
            $0.sets = sets
        }
    }
    
    func testUpdateID() async {
        let sets: [StudySet] = .testMock
        let unitCount = Random.int(from: 0, to: 9999)
        let id = sets.randomElement()!.id
        
        let store = TestStore(
            initialState: SelectStudySet.State(
                sets: sets
            ),
            reducer: { SelectStudySet() },
            withDependencies: {
                $0.studySetClient.countUnits = { _ in unitCount }
            }
        )
        
        await store.send(.updateID(id)) {
            $0.selectedID = id
            $0.unitCount = unitCount
        }
        
        await store.receive(.idUpdated(store.state.selectedSet))
    }
    
    func testUpdateID_toNil() async {
        let sets: [StudySet] = .testMock
        let unitCount = Random.int(from: 0, to: 9999)
        let id = sets.randomElement()!.id
        
        let store = TestStore(
            initialState: SelectStudySet.State(
                sets: sets,
                selectedID: id,
                unitCount: unitCount
            ),
            reducer: { SelectStudySet() }
        )
        
        await store.send(.updateID(nil)) {
            $0.selectedID = nil
            $0.unitCount = nil
        }
        
        await store.receive(.idUpdated(nil))
    }
    
}

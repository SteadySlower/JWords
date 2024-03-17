//
//  HomeListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import XCTest
@testable import JWords

private let fetchedAllSets: [StudySet] = .testMock
private let fetchedSetsNotClosed: [StudySet] = .notClosedTestMock

final class HomeListTest: XCTestCase {
    
    @MainActor
    private func get_test_store() async -> TestStore<HomeList.State, HomeList.Action> {
        return TestStore(
            initialState: HomeList.State(),
            reducer: { HomeList() })
        {
            $0.studySetClient.fetch = { bool in bool ? fetchedAllSets : fetchedSetsNotClosed }
        }
    }
    
    @MainActor
    func test_fetchSets() async {
        let store = await get_test_store()
        
        await store.send(.fetchSets) {
            $0.sets = fetchedSetsNotClosed
        }
    }
    
    @MainActor
    func test_setIncludeClosed() async {
        let store = await get_test_store()
        
        XCTAssertEqual(store.state.includeClosed, false)
        
        await store.send(.setIncludeClosed(true)) {
            $0.includeClosed = true
            $0.sets = fetchedAllSets
        }
        
        await store.send(.setIncludeClosed(false)) {
            $0.includeClosed = false
            $0.sets = fetchedSetsNotClosed
        }
    }
    
    @MainActor
    func test_toAddSet() async {
        let store = await get_test_store()
        
        XCTAssertEqual(store.state.destination, nil)
        
        await store.send(.toAddSet) {
            $0.destination = .addSet(.init())
        }
    }
    
    @MainActor
    func test_destination_present_addSet_added() async {
        let store = await get_test_store()
        
        let set: StudySet = .testMock
        
        await store.send(.toAddSet) {
            $0.destination = .addSet(.init())
        }
        
        await store.send(.destination(.presented(.addSet(.added(set))))) {
            $0.sets.insert(set, at: 0)
            $0.destination = nil
        }
    }
}



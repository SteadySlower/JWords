//
//  KanjiSetListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class KanjiSetListTest: XCTestCase {
    
    @MainActor
    func test_fetchSets() async {
        let kanjiSets: [KanjiSet] = .testMock
        let store = TestStore(
            initialState: KanjiSetList.State(),
            reducer: { KanjiSetList() },
            withDependencies: {
                $0.kanjiSetClient.fetch = { kanjiSets }
            }
        )
        await store.send(.fetchSets) {
            $0.sets = kanjiSets
        }
    }
    
    @MainActor
    func test_toAddKanjiSet() async {
        let store = TestStore(
            initialState: KanjiSetList.State(),
            reducer: { KanjiSetList() }
        )
        await store.send(.toAddKanjiSet) {
            $0.destination = .addKanjiSet(.init())
        }
    }
    
    @MainActor
    func test_destination_presented_addKanjiSet_added() async {
        let kanjiSet: KanjiSet = .testMock
        let store = TestStore(
            initialState: KanjiSetList.State(
                sets: .testMock,
                destination: .addKanjiSet(.init())
            ),
            reducer: { KanjiSetList() }
        )
        await store.send(\.destination.addKanjiSet.added, kanjiSet) {
            $0.sets.insert(kanjiSet, at: 0)
            $0.destination = nil
        }
    }
    
    @MainActor
    func test_destination_presented_addKanjiSet_cancel() async {
        let store = TestStore(
            initialState: KanjiSetList.State(
                sets: .testMock,
                destination: .addKanjiSet(.init())
            ),
            reducer: { KanjiSetList() }
        )
        await store.send(\.destination.addKanjiSet.cancel) {
            $0.destination = nil
        }
    }
}

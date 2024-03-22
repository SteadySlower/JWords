//
//  KanjiListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class KanjiListTest: XCTestCase {
    
    @MainActor
    func test_fetchKanjis() async {
        let fetchKanjiCount = KanjiList.NUMBER_OF_KANJI_IN_A_PAGE
        let fetched: [Kanji] = .testMock(count: fetchKanjiCount)
        
        let store = TestStore(
            initialState: KanjiList.State(kanjis: []),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.fetch = { _ in fetched }
            }
        )
        
        await store.send(.fetchKanjis) {
            $0.kanjis.append(contentsOf:
                IdentifiedArray(
                    uniqueElements: fetched.map { DisplayKanji.State(kanji: $0) }
                )
            )
        }
    }
    
    @MainActor
    func test_fetchKanjis_lastPage() async {
        let fetchKanjiCount = Random.int(from: 0, to: KanjiList.NUMBER_OF_KANJI_IN_A_PAGE - 1)
        let fetched: [Kanji] = .testMock(count: fetchKanjiCount)
        
        let store = TestStore(
            initialState: KanjiList.State(kanjis: []),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.fetch = { _ in fetched }
            }
        )
        
        await store.send(.fetchKanjis) {
            $0.kanjis.append(contentsOf:
                IdentifiedArray(
                    uniqueElements: fetched.map { DisplayKanji.State(kanji: $0) }
                )
            )
            $0.isLastPage = true
        }
    }
    
    @MainActor
    func test_kanji_edit() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(uniqueElements: kanjis.map { .init(kanji: $0) })
            ),
            reducer: { KanjiList() }
        )
        
        let toEdit: Kanji = kanjis.randomElement()!
        
        await store.send(\.kanji[id: toEdit.id].edit, toEdit) {
            $0.destination = .edit(.init(toEdit))
        }
    }
    
    @MainActor
    func test_kanji_addToWrite() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let kanjiSets: [KanjiSet] = .testMock
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(uniqueElements: kanjis.map { .init(kanji: $0) })
            ),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiSetClient.fetch =  { kanjiSets }
            }
        )
        
        let toAddToWrite: Kanji = kanjis.randomElement()!
        
        await store.send(\.kanji[id: toAddToWrite.id].addToWrite, toAddToWrite) {
            $0.destination = .addWriting(.init(kanji: toAddToWrite, kanjiSets: kanjiSets))
        }
    }
    
    @MainActor
    func test_destination_presented_edit_edited() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let toEdit = kanjis.randomElement()!
        
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: kanjis.map { DisplayKanji.State(kanji: $0) }
                ),
                destination: .edit(.init(toEdit))
            ),
            reducer: { KanjiList() }
        )
        
        let edited: Kanji = .testMock
        
        await store.send(\.destination.edit.edited, edited) {
            $0.kanjis.updateOrAppend(DisplayKanji.State(kanji: edited))
            $0.destination = nil
        }
    }
    
    @MainActor
    func test_searchKanji_queryRemoved() async {
        let fetched: [Kanji] = .testMock(count: KanjiList.NUMBER_OF_KANJI_IN_A_PAGE)
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: []
            ),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.fetch = { _ in fetched }
            }
        )
        
        await store.send(\.searchKanji.queryRemoved) {
            $0.kanjis = IdentifiedArray(
                uniqueElements: fetched.map { DisplayKanji.State(kanji: $0) }
            )
        }
    }
    
    @MainActor
    func test_searchKanji_kanjiSearched() async {
        let existingKanjis: [Kanji] = .testMock(count: Random.int(from: 0, to: 100))
        let searched: [Kanji] = .testMock(count: Random.int(from: 0, to: 100))
        
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: existingKanjis.map { DisplayKanji.State(kanji: $0) }
                )
            ),
            reducer: { KanjiList() }
        )
        
        await store.send(\.searchKanji.kanjiSearched, searched) {
            $0.kanjis = IdentifiedArray(uniqueElements: searched.map { DisplayKanji.State(kanji: $0) })
        }
    }
    
}

//
//  KanjiListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class KanjiListTest: XCTestCase {
    
    func test_onAppear() async {
        let fetchKanjiCount = KanjiList.NUMBER_OF_KANJI_IN_A_PAGE
        let fetched: [Kanji] = .testMock(count: fetchKanjiCount)
        
        let store = TestStore(
            initialState: KanjiList.State(kanjis: []),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.fetch = { _ in fetched }
            }
        )
        
        await store.send(.onAppear)
        
        await store.receive(.fetchKanjis) {
            $0.kanjis.append(contentsOf:
                IdentifiedArray(
                    uniqueElements: fetched.map { DisplayKanji.State(kanji: $0) }
                )
            )
        }
    }
    
    func test_fetchKanji() async {
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
    
    func test_fetchKanji_lastPage() async {
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
    
    func test_kanji_showSamples() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let kanji: Kanji = kanjis.randomElement()!
        let units: [StudyUnit] = .testMock
        
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: kanjis.map { DisplayKanji.State(kanji: $0) }
                )
            ),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.kanjiUnits = { _ in units }
            }
        )
        
        await store.send(.kanji(kanji.id, .showSamples(kanji))) {
            $0.studyKanjiSamples = StudyKanjiSamples.State(kanji: kanji, units: units)
        }
    }
    
    func test_showStudyView_false() async {
        let kanji: Kanji = .testMock
        let units: [StudyUnit] = .testMock
        
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: [],
                studyKanjiSamples: StudyKanjiSamples.State(
                    kanji: kanji,
                    units: units
                )
            ),
            reducer: { KanjiList() }
        )
        
        await store.send(.showStudyView(false)) {
            $0.studyKanjiSamples = nil
        }
    }
    
    func test_showEditView_false() async {
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: [],
                edit: EditKanji.State(.testMock)
            ),
            reducer: { KanjiList() }
        )
        
        await store.send(.showEditView(false)) {
            $0.edit = nil
        }
    }
    
    func test_edit_cancel() async {
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: [],
                edit: EditKanji.State(.testMock)
            ),
            reducer: { KanjiList() }
        )
        
        await store.send(.edit(.cancel)) {
            $0.edit = nil
        }
    }
    
    func test_edit_edited() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let toEdit = kanjis.randomElement()!
        
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: kanjis.map { DisplayKanji.State(kanji: $0) }
                ),
                edit: EditKanji.State(toEdit)
            ),
            reducer: { KanjiList() }
        )
        
        let edited = Kanji(id: toEdit.id,
                           kanjiText: toEdit.kanjiText,
                           meaningText: Random.string,
                           ondoku: Random.string,
                           kundoku: Random.string,
                           createdAt: toEdit.createdAt,
                           usedIn: toEdit.usedIn)
        
        await store.send(.edit(.edited(edited))) {
            $0.kanjis.updateOrAppend(DisplayKanji.State(kanji: edited))
            $0.edit = nil
        }
    }
    
    func test_searchKanji_updateQuery_with_empty_string() async {
        let fetched: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: []
            ),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.fetch = { _ in fetched }
            }
        )
        
        await store.send(.searchKanji(.updateQuery("")))
        
        await store.receive(.fetchKanjis) {
            $0.kanjis = IdentifiedArray(
                uniqueElements: fetched.map { DisplayKanji.State(kanji: $0) }
            )
            $0.isLastPage = fetched.count < KanjiList.NUMBER_OF_KANJI_IN_A_PAGE
        }
    }
    
    func test_searchKanji_kanjiSearched() async {
        let existingKanjis: [Kanji] = .testMock(count: Random.int(from: 0, to: 100))
        let searched: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        
        let store = TestStore(
            initialState: KanjiList.State(
                kanjis: IdentifiedArray(
                    uniqueElements: existingKanjis.map { DisplayKanji.State(kanji: $0) }
                )
            ),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.search = { _ in searched }
            }
        )
        
        await store.send(.searchKanji(.kanjiSearched(searched))) {
            $0.kanjis = IdentifiedArray(uniqueElements: searched.map { DisplayKanji.State(kanji: $0) })
        }
    }
    
}

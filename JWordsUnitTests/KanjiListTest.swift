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
    
    func test_kanjiCellTapped() async {
        let kanji: Kanji = .testMock
        let units: [StudyUnit] = .testMock
        
        let store = TestStore(
            initialState: KanjiList.State(kanjis: []),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.kanjiUnits = { _ in units }
            }
        )
        
        await store.send(.kanjiCellTapped(kanji)) {
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
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.kanjiUnits = { _ in units }
            }
        )
        
        await store.send(.showStudyView(false)) {
            $0.studyKanjiSamples = nil
        }
    }
    
}

//
//  StudyOneUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class StudyOneUnitTest: XCTestCase {
    
    @MainActor
    func test_toggleFront() async {
        let store = TestStore(
            initialState: StudyOneUnit.State(unit: .testMock),
            reducer: { StudyOneUnit() }
        )
        
        await store.send(.toggleFront) {
            $0.isFront.toggle()
        }
    }
    
    @MainActor
    func test_updateStudyState_not_isLocked() async {
        let unit: StudyUnit = .testMock
        let newState = StudyState.allCases.filter { $0 != unit.studyState }.randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: unit,
                isLocked: false
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, _ in newState }
            }
        )
        
        await store.send(.updateStudyState(Random.studyState)) {
            $0.studyState = newState
        }
    }
    
    @MainActor
    func test_updateStudyState_isLocked() async {
        let unit: StudyUnit = .testMock
        let newState = StudyState.allCases.filter { $0 != unit.studyState }.randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: .testMock,
                isLocked: true
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, _ in newState }
            }
        )
        
        await store.send(.updateStudyState(Random.studyState))
    }
    
    @MainActor
    func test_showKanjis() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: .testMock
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.kanjiClient.unitKanjis = { _ in kanjis }
            }
        )
        
        store.assert {
            $0.kanjis = []
        }
        
        await store.send(.showKanjis) {
            $0.kanjis = kanjis
        }
        
        await store.send(.showKanjis) {
            $0.kanjis = []
        }
    }
    
}

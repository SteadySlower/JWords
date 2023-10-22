//
//  TodaySelectionTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/22/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class TodaySelectionTest: XCTestCase {
    
    func test_onAppear() async {
        let todaySets: [StudySet] = .testMock
        let reviewSets: [StudySet] = .testMock
        let otherSets: [StudySet] = .testMock
        let allSets = (todaySets + reviewSets + otherSets).shuffled()
        
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: todaySets,
                reviewSets: reviewSets
            ),
            reducer: { TodaySelection() },
            withDependencies: {
                $0.studySetClient.fetch = { _ in allSets }
            }
        )
        
        let schedules = store.state.schedules
        
        await store.send(.onAppear) {
            $0.sets = allSets.sorted(by: { set1, set2 in
                if schedules[set1, default: .none] != .none
                    && schedules[set2, default: .none] == .none {
                    return true
                } else {
                    return false
                }
            })
        }
    }
    
    func test_studyButtonTapped_noneToStudy() async {
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: .testMock,
                reviewSets: .testMock
            ),
            reducer: { TodaySelection() }
        )
        
        let noneSet: StudySet = .testMock
        
        await store.send(.studyButtonTapped(noneSet)) {
            $0.schedules[noneSet] = .study
        }
    }
    
    func test_studyButtonTapped_studyToNone() async {
        let studySets: [StudySet] = .testMock
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: studySets,
                reviewSets: .testMock
            ),
            reducer: { TodaySelection() }
        )
        
        let studySet = studySets.randomElement()!
        
        await store.send(.studyButtonTapped(studySet)) {
            $0.schedules[studySet] = Schedule.none
        }
    }
    
    func test_studyButtonTapped_reviewToStudy() async {
        let reviewSets: [StudySet] = .testMock
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: .testMock,
                reviewSets: reviewSets
            ),
            reducer: { TodaySelection() }
        )
        
        let reviewSet = reviewSets.randomElement()!
        
        await store.send(.studyButtonTapped(reviewSet)) {
            $0.schedules[reviewSet] = .study
        }
    }
    
}

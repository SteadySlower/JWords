//
//  TodaySelectionTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/22/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class TodaySelectionTest: XCTestCase {
    
    @MainActor
    func test_fetchSets() async {
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
        
        await store.send(.fetchSets) {
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
    
    @MainActor
    func test_toggleStudy_none_to_study() async {
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: .testMock,
                reviewSets: .testMock
            ),
            reducer: { TodaySelection() }
        )
        
        let noneSet: StudySet = .testMock
        
        await store.send(.toggleStudy(noneSet)) {
            $0.schedules[noneSet] = .study
        }
    }
    
    @MainActor
    func test_toggleStudy_study_to_none() async {
        let studySets: [StudySet] = .testMock
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: studySets,
                reviewSets: .testMock
            ),
            reducer: { TodaySelection() }
        )
        
        let studySet = studySets.randomElement()!
        
        await store.send(.toggleStudy(studySet)) {
            $0.schedules[studySet] = Schedule.none
        }
    }
    
    @MainActor
    func test_toggleStudy_review_to_study() async {
        let reviewSets: [StudySet] = .testMock
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: .testMock,
                reviewSets: reviewSets
            ),
            reducer: { TodaySelection() }
        )
        
        let reviewSet = reviewSets.randomElement()!
        
        await store.send(.toggleStudy(reviewSet)) {
            $0.schedules[reviewSet] = .study
        }
    }
    
    @MainActor
    func test_toggleReview_none_to_reivew() async {
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: .testMock,
                reviewSets: .testMock
            ),
            reducer: { TodaySelection() }
        )
        
        let noneSet: StudySet = .testMock
        
        await store.send(.toggleReview(noneSet)) {
            $0.schedules[noneSet] = .review
        }
    }
    
    @MainActor
    func test_toggleReview_review_to_none() async {
        let reviewSets: [StudySet] = .testMock
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: .testMock,
                reviewSets: reviewSets
            ),
            reducer: { TodaySelection() }
        )
        let reviewSet = reviewSets.randomElement()!
        await store.send(.toggleReview(reviewSet)) {
            $0.schedules[reviewSet] = Schedule.none
        }
    }
    
    @MainActor
    func test_toggleReview_review_to_study() async {
        let studySets: [StudySet] = .testMock
        let store = TestStore(
            initialState: TodaySelection.State(
                todaySets: studySets,
                reviewSets: .testMock
            ),
            reducer: { TodaySelection() }
        )
        let studySet = studySets.randomElement()!
        await store.send(.toggleReview(studySet)) {
            $0.schedules[studySet] = .review
        }
    }
}

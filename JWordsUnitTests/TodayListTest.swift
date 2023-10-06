//
//  TodayListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/05.
//

import ComposableArchitecture
import XCTest

@testable import JWords

fileprivate let mockSets: [StudySet] = .testMock(
    none: Random.int(from: 0, to: 10),
    study: Random.int(from: 0, to: 10),
    review: Random.int(from: 0, to: 10)
)

fileprivate let mockSchedule: TodaySchedule = .testMock(ids: mockSets.map { $0.id })

fileprivate var fetchUnitCount = 0

fileprivate var mockUnits: [StudyUnit] {
    var result = [StudyUnit]()
    let count = Random.int(from: 0, to: 10)
    let endIndex = fetchUnitCount + count
    
    for i in fetchUnitCount..<(fetchUnitCount + count) {
        result.append(.init(index: i))
    }
    
    fetchUnitCount = endIndex
    
    return result
}

@MainActor
final class TodayListTest: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(
            initialState: TodayList.State(),
            reducer: TodayList()
        ) {
            $0.studySetClient.fetch = { _ in mockSets }
            $0.scheduleClient.fetch = { mockSchedule }
            $0.studyUnitClient.fetch = { _ in mockUnits }
            $0.studyUnitClient.fetchAll = { _ in .mock }
        }
        
        await store.send(.onAppear) {
            let todaySets = TodaySets(sets: mockSets, schedule: mockSchedule)
            $0.studySets = todaySets.study
            $0.reviewedSets = todaySets.reviewed
            $0.reviewSets = todaySets.review.filter {
                !todaySets.reviewed.contains($0) }
            $0.onlyFailUnits = .mock
            $0.todayStatus = .init(
                sets: todaySets.study.count,
                total: [StudyUnit].mock.count,
                wrong: $0.onlyFailUnits.count
            )
        }
    }
}

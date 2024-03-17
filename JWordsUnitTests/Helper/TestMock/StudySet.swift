//
//  StudySet.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/14.
//

import Foundation
@testable import JWords

extension StudySet {
    static var testMock: Self {
        .init(
            title: Random.string,
            createdAt: Random.dateWithinYear,
            closed: Bool.random()
        )
    }
    
    static var notClosedTestMock: Self {
        .init(
            title: Random.string,
            createdAt: Random.dateWithinYear,
            closed: true
        )
    }
}

extension Array where Element == StudySet {
    static var testMock: Self {
        var result = [StudySet]()
        for _ in 0..<Random.int(from: 1, to: 100) {
            result.append(.testMock)
        }
        return result
    }
    
    static var notClosedTestMock: Self {
        var result = [StudySet]()
        for _ in 0..<Random.int(from: 1, to: 100) {
            result.append(.notClosedTestMock)
        }
        return result
    }
}

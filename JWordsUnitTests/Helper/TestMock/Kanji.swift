//
//  Kanji.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import Foundation
@testable import JWords

extension Kanji {
    static var testMock: Self {
        .init(
            kanjiText: Random.string,
            meaningText: Random.string,
            ondoku: Random.string,
            kundoku: Random.string,
            studyState: .init(rawValue: Random.int(from: 0, to: 2))!,
            createdAt: Random.dateWithinYear,
            usedIn: Random.int(from: 0, to: 100)
        )
    }
}

extension Array where Element == Kanji {
    static func testMock(count: Int) -> Self {
        var result = [Kanji]()
        for _ in 0..<count {
            result.append(.testMock)
        }
        return result
    }
}

//
//  KanjiSet.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/9/24.
//

import Foundation
import Model
@testable import JWords

extension KanjiSet {
    static var testMock: Self {
        .init(title: Random.string, createdAt: Random.dateWithinYear, closed: Random.bool)
    }
}

extension Array where Element == KanjiSet {
    static var testMock: Self {
        var result = [KanjiSet]()
        for _ in 0..<Random.int(from: 1, to: 100) {
            result.append(.testMock)
        }
        return result
    }
}

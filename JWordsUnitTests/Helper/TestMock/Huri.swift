//
//  Huri.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import Foundation
@testable import JWords
import Huri

extension Huri {
    static var testMock: Self {
        .init(id: Random.string, huriString: Random.string)
    }
}

extension Array where Element == Huri {
    static var testMock: Self {
        var result = [Huri]()
        for _ in 0..<Random.int(from: 1, to: 100) {
            result.append(.testMock)
        }
        return result
    }
}

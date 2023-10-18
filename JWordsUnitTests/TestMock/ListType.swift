//
//  ListType.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/18/23.
//

import Foundation
@testable import JWords

extension Array where Element == ListType {
    static var testMock: Self {
        let count = Random.int(from: 2, to: ListType.allCases.count)
        var result = ListType.allCases.shuffled()
        while result.count > count {
            result.removeLast()
        }
        return result
    }
}

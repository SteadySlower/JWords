//
//  OCRResult.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/16/23.
//

import Foundation
@testable import JWords

extension OCRResult {
    static var testMock: Self {
        .init(
            string: Random.string,
            position: .init(
                x: CGFloat(Random.int(from: 1, to: 99999999)),
                y: CGFloat(Random.int(from: 1, to: 99999999)),
                width: CGFloat(Random.int(from: 1, to: 99999999)),
                height: CGFloat(Random.int(from: 1, to: 99999999))
            )
        )
    }
}

extension Array where Element == OCRResult {
    static var testMock: Self {
        var result = [OCRResult]()
        for _ in 0..<Random.int(from: 0, to: 100) {
            result.append(.testMock)
        }
        return result
    }
}

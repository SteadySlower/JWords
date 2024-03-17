//
//  StudyUnit.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/14.
//

import Foundation
@testable import JWords

extension StudyUnit {
    static var testMock: Self {
        .init(kanjiText: Random.string,
              meaningText: Random.string,
              studyState: [.undefined, .success, .fail].randomElement() ?? .undefined,
              studySets: []
        )
    }
    
    static var undefinedTestMock: Self {
        .init(kanjiText: Random.string,
              meaningText: Random.string,
              studyState: .undefined,
              studySets: []
        )
    }
    
    static var successTestMock: Self {
        .init(kanjiText: Random.string,
              meaningText: Random.string,
              studyState: .success,
              studySets: []
        )
    }
    
    static var failTestMock: Self {
        .init(kanjiText: Random.string,
              meaningText: Random.string,
              studyState: .fail,
              studySets: []
        )
    }
}

extension Array where Element == StudyUnit {
    static var testMock: Self {
        var result = [StudyUnit]()
        for _ in 0..<Random.int(from: 0, to: 100) {
            result.append(.testMock)
        }
        return result
    }
    
    static var toStudyTestMock: Self {
        var result = [StudyUnit]()
        for _ in 0..<Random.int(from: 0, to: 100) {
            result.append(.failTestMock)
        }
        return result
    }
}


//
//  CDWordClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/08.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct CDWordClient {
    private static let cd: CoreDataClient = CoreDataClient.shared
    var units: (StudySet) throws -> [StudyUnit]
    var studyState: (StudyUnit, StudyState) throws -> StudyState
//    var edit: @Sendable (Word, WordInput) async throws -> Word
//    var add: @Sendable (WordInput) async throws -> Bool // interim return type
}

extension DependencyValues {
  var cdWordClient: CDWordClient {
    get { self[CDWordClient.self] }
    set { self[CDWordClient.self] = newValue }
  }
}

extension CDWordClient: DependencyKey {
  static let liveValue = CDWordClient(
    units: { studySet in try cd.fetchUnits(of: studySet) },
    studyState: { studyUnit, newState in try cd.updateStudyState(unit: studyUnit, newState: newState); return newState }
  )
}

extension CDWordClient: TestDependencyKey {
  static let previewValue = Self(
    units: { _ in return .mock },
    studyState: { _, newState in return newState }
  )

  static let testValue = Self(
    units: unimplemented("\(Self.self).units"),
    studyState: unimplemented("\(Self.self).studyState")
  )
    
    static private func makeMockEditWord(_ word: Word, _ wordInput: WordInput) -> Word {
        return Word(id: word.id,
                    wordBookID: word.wordBookID,
                    meaningText: wordInput.meaningText,
                    meaningImageURL: word.meaningImageURL,
                    ganaText: wordInput.ganaText,
                    ganaImageURL: word.ganaImageURL,
                    kanjiText: wordInput.kanjiText,
                    kanjiImageURL: word.kanjiImageURL,
                    studyState: word.studyState,
                    createdAt: word.createdAt)
    }
}

extension Array where Element == StudyUnit {
    static var mock: [StudyUnit] {
        var result = [StudyUnit]()
        for i in 0..<10 {
            result.append(StudyUnit(index: i))
        }
        return result
    }
}

//
//  WordBookClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/21.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct WordBookClient {
    private static let wordBookService: WordBookService = ServiceManager.shared.wordBookService
    var wordBooks: @Sendable () async throws -> [WordBook]
}

extension DependencyValues {
  var wordBookClient: WordBookClient {
    get { self[WordBookClient.self] }
    set { self[WordBookClient.self] = newValue }
  }
}

extension WordBookClient: DependencyKey {
  static let liveValue = WordBookClient(
    wordBooks: {
        return try await withCheckedThrowingContinuation { continuation in
            wordBookService.getWordBooks { wordBooks, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else if let wordBooks = wordBooks {
                    continuation.resume(with: .success(wordBooks))
                } else {
                    continuation.resume(with: .failure(AppError.generic(massage: "wordBooks is nil in WordBookClient_wordBooks")))
                }
            }
        }
    }
  )
}

extension WordBookClient: TestDependencyKey {
  static let previewValue = Self(
    wordBooks: { .mock }
  )

  static let testValue = Self(
    wordBooks: unimplemented("\(Self.self).wordBooks")
  )
}

extension Array where Element == WordBook {
    static let mock: [WordBook] = {
        var result = [WordBook]()
        for i in 0..<10 {
            result.append(WordBook(title: "단어장 \(i)"))
        }
        return result
    }()
}

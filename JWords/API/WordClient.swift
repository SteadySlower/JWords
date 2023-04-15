//
//  WordClient.swift
//  JWords
//
//  Created by JW Moon on 2023/04/15.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct WordClient {
    private static let wordService: WordService = ServiceManager.shared.wordService
    var words: @Sendable (WordBook) async throws -> [Word]
}

extension DependencyValues {
  var wordClient: WordClient {
    get { self[WordClient.self] }
    set { self[WordClient.self] = newValue }
  }
}

extension WordClient: DependencyKey {
  static let liveValue = WordClient(
    words: { wordBook in
        return try await withCheckedThrowingContinuation { continuation in
            wordService.getWords(wordBook: wordBook) { words, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else if let words = words {
                    continuation.resume(with: .success(words))
                } else {
                    continuation.resume(with: .failure(AppError.generic(massage: "words is nil in WordClient_words")))
                }
            }
        }
    }
  )
}

extension WordClient: TestDependencyKey {
  static let previewValue = Self(
    words: { _ in .mock }
  )

  static let testValue = Self(
    words: unimplemented("\(Self.self).forecast")
  )
}

extension Array where Element == Word {
    static let mock = [
        Word(), Word(), Word(), Word(), Word(), Word(), Word(), Word()
    ]
}

extension WordBook {
    static let mock = WordBook(title: "Mock Word Book")
}

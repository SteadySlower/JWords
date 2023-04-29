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
    var moveWords: @Sendable (WordBook, WordBook?, [Word]) async throws -> Void
    var closeBook: @Sendable (WordBook) async throws -> Void
    var addBook: @Sendable (String, FrontType) async throws -> Void
    var wordCount: @Sendable (WordBook) async throws -> Int
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
    },
    moveWords: { from, to, words in
        return try await withCheckedThrowingContinuation { continuation in
            wordBookService.moveWords(of: from, to: to, toMove: words) { error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(()))
                }
            }
        }
    },
    closeBook: { wordBook in
        return try await withCheckedThrowingContinuation { continuation in
            wordBookService.closeWordBook(wordBook) { error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(()))
                }
            }
        }
    },
    addBook: { title, type in
        return try await withCheckedThrowingContinuation { continuation in
            wordBookService.saveBook(title: title, preferredFrontType: type) { error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(()))
                }
            }
        }
    },
    wordCount: { wordBook in
        return try await withCheckedThrowingContinuation { continuation in
            wordBookService.countWords(in: wordBook) { count, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else if let count = count {
                    continuation.resume(with: .success(count))
                } else {
                    continuation.resume(with: .failure(AppError.generic(massage: "count is nil in WordBookClient_wordCount")))
                }
            }
        }
    }
  )
}

extension WordBookClient: TestDependencyKey {
    static let previewValue = Self(
    wordBooks: { try await Task.sleep(nanoseconds: 3 * 1_000_000_000); return .mock },
    moveWords: { _, _, _ in try await Task.sleep(nanoseconds: 1 * 1_000_000_000); print("preview client: move words") },
    closeBook: { _ in try await Task.sleep(nanoseconds: 3 * 1_000_000_000); print("preview client: close books")  },
    addBook: { _, _ in try await Task.sleep(nanoseconds: 1 * 1_000_000_000); print("preview client: add book") },
    wordCount: { _ in try await Task.sleep(nanoseconds: 1 * 1_000_000_000); return 10 print("preview client: word count") }
  )

  static let testValue = Self(
    wordBooks: unimplemented("\(Self.self).wordBooks"),
    moveWords: unimplemented("\(Self.self).moveWords"),
    closeBook: unimplemented("\(Self.self).closeBook"),
    addBook: unimplemented("\(Self.self).addBook"),
    wordCount: unimplemented("\(Self.self).wordCount")
  )
}

extension Array where Element == WordBook {
    static let mock: [WordBook] = {
        var result = [WordBook]()
        for i in 0..<10 {
            result.append(WordBook(index: i))
        }
        return result
    }()
}

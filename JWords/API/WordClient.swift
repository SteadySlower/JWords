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
    var studyState: @Sendable (Word, StudyState) async throws -> StudyState
    var edit: @Sendable (Word, WordInput) async throws -> Word
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
    },
    studyState: { word, studyState in
        return try await withCheckedThrowingContinuation { continuation in
            wordService.updateStudyState(word: word, newState: studyState) { error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else {
                    continuation.resume(with: .success(studyState))
                }
            }
        }
    },
    edit: { word, wordInput in
        return try await withCheckedThrowingContinuation { continuation in
            wordService.updateWord(word, wordInput) { word, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else if let word = word {
                    continuation.resume(with: .success(word))
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
    words: { _ in .mock },
    studyState: { word, state in state },
    edit: { word, wordInput in makeMockEditWord(word, wordInput) }
//    edit: { word, wordInput in throw AppError.generic(massage: "mock error") }
  )

  static let testValue = Self(
    words: unimplemented("\(Self.self).words"),
    studyState: unimplemented("\(Self.self).studyState"),
    edit: unimplemented("\(Self.self).edit")
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

extension Array where Element == Word {
    static let mock: [Word] = {
        var result = [Word]()
        for i in 0..<10 {
            result.append(Word(index: i))
        }
        return result
    }()
}

extension WordBook {
    static let mock = WordBook(title: "Mock Word Book")
}

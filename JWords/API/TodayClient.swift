//
//  TodayClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/21.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct TodayClient {
    private static let todayService: TodayService = ServiceManager.shared.todayService
    var updateReviewed: @Sendable (String) async throws -> Void
    var autoUpdateTodayBooks: @Sendable ([WordBook]) async throws -> Void
    var getTodayBooks: @Sendable () async throws -> TodayBooks
}

extension DependencyValues {
  var todayClient: TodayClient {
    get { self[TodayClient.self] }
    set { self[TodayClient.self] = newValue }
  }
}

extension TodayClient: DependencyKey {
  static let liveValue = TodayClient(
        updateReviewed: { id in
            return try await withCheckedThrowingContinuation { continuation in
                todayService.updateReviewed(id) { error in
                    if let error = error {
                        continuation.resume(with: .failure(error))
                    } else {
                        continuation.resume(with: .success(()))
                    }
                }
            }
        },
        autoUpdateTodayBooks: { wordBooks in
            return try await withCheckedThrowingContinuation { continuation in
                todayService.autoUpdateTodayBooks(wordBooks) { error in
                    if let error = error {
                        continuation.resume(with: .failure(error))
                    } else {
                        continuation.resume(with: .success(()))
                    }
                }
            }
        },
        getTodayBooks: {
            return try await withCheckedThrowingContinuation { continuation in
                todayService.getTodayBooks { todayBooks, error in
                    if let error = error {
                        continuation.resume(with: .failure(error))
                    } else if let todayBooks = todayBooks {
                        continuation.resume(with: .success(todayBooks))
                    } else {
                        continuation.resume(with: .failure(AppError.generic(massage: "today client failure: today book is nil")))
                    }
                }
            }
        }
  )
}

extension TodayClient: TestDependencyKey {
  static let previewValue = Self(
    updateReviewed: { _ in try await Task.sleep(nanoseconds: 2 * 1_000_000_000); print("preview client: update reviewed")  },
    autoUpdateTodayBooks: { _ in try await Task.sleep(nanoseconds: 1 * 1_000_000_000); print("preview client: auto update todayBooks") },
    getTodayBooks: { try await Task.sleep(nanoseconds: 1 * 1_000_000_000); return .empty }
  )

  static let testValue = Self(
    updateReviewed: unimplemented("\(Self.self).updateReviewed"),
    autoUpdateTodayBooks: unimplemented("\(Self.self).autoUpdateTodayBooks"),
    getTodayBooks: unimplemented("\(Self.self).getTodayBooks")
  )
}

extension TodayBooks {
    static let empty = TodayBooks(studyIDs: [],
                                 reviewIDs: [],
                                 reviewedIDs: [],
                                 createdAt: Date())
}



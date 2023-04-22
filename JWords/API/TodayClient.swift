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
        }
  )
}

extension TodayClient: TestDependencyKey {
  static let previewValue = Self(
    updateReviewed: { _ in try await Task.sleep(nanoseconds: 2 * 1_000_000_000); print("preview client: update reviewed")  }
  )

  static let testValue = Self(
    updateReviewed: unimplemented("\(Self.self).updateReviewed")
  )
}



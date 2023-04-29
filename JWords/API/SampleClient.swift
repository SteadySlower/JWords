//
//  SampleClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/28.
//

import ComposableArchitecture

struct SampleClient {
    private static let sampleService: SampleService = ServiceManager.shared.sampleService
    var samplesByMeaning: @Sendable (String) async throws -> [Sample]
}

extension DependencyValues {
  var sampleClient: SampleClient {
    get { self[SampleClient.self] }
    set { self[SampleClient.self] = newValue }
  }
}

extension SampleClient: DependencyKey {
  static let liveValue = SampleClient(
    samplesByMeaning: { meaning in
        return try await withCheckedThrowingContinuation { continuation in
            sampleService.getSamplesByMeaning(meaning) { samples, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                } else if let samples = samples {
                    continuation.resume(with: .success(samples))
                } else {
                    continuation.resume(with: .failure(AppError.generic(massage: "samples are nil in SampleClient_samplesByMeaning")))
                }
            }
        }
    }
  )
}

extension SampleClient: TestDependencyKey {
  static let previewValue = Self(
    samplesByMeaning: { _ in try await Task.sleep(nanoseconds: 2 * 1_000_000_000); return .mock }
  )

  static let testValue = Self(
    samplesByMeaning: unimplemented("\(Self.self).samplesByMeaning")
  )
}

extension Array where Element == Sample {
    static var mock: [Sample] {
        var result = [Sample]()
        for i in 0..<10 {
            result.append(Sample(index: i))
        }
        return result
    }
}

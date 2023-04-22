//
//  ImageFetcher.swift
//  JWords
//
//  Created by JW Moon on 2023/04/22.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import Kingfisher

struct ImageClient {
    var prefetchImages: @Sendable ([Word]) -> Void
}

extension DependencyValues {
  var imageClient: ImageClient {
    get { self[ImageClient.self] }
    set { self[ImageClient.self] = newValue }
  }
}

extension ImageClient: DependencyKey {
  static let liveValue = ImageClient(
    prefetchImages: { words in
        var urls = [URL]()
        for word in words {
            urls.append(contentsOf: getWordURLs(word))
        }
        let prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
            print("prefetched image: \(completedResources)")
        }
        prefetcher.start()
    }
  )
    
    private static func getWordURLs(_ word: Word) -> [URL] {
        return [word.ganaImageURL, word.kanjiImageURL, word.meaningImageURL]
            .filter { !$0.isEmpty }
            .compactMap { URL(string: $0) }
    }
}

extension ImageClient: TestDependencyKey {
  static let previewValue = Self(
    prefetchImages: { _ in print("preview client: image prefetched")  }
  )

  static let testValue = Self(
    prefetchImages: unimplemented("\(Self.self).prefetchImages")
  )
}




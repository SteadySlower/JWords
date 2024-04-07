//
//  PasteBoardClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/28.
//

import ComposableArchitecture
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import XCTestDynamicOverlay
import Model
import PasteBoardKit

struct PasteBoardClient {
    private static let pbService = PasteBoardService.shared
    var fetchImage: () -> InputImageType?
    var copyString: (String) -> Void
}

extension DependencyValues {
  var pasteBoardClient: PasteBoardClient {
    get { self[PasteBoardClient.self] }
    set { self[PasteBoardClient.self] = newValue }
  }
}

extension PasteBoardClient: DependencyKey {
  static let liveValue = PasteBoardClient(
    fetchImage: {
        pbService.fetchImage()
    },
    copyString: { text in
        pbService.copyText(text)
    }
  )
}

extension PasteBoardClient: TestDependencyKey {
  static let previewValue = Self(
    fetchImage: {
        #if os(iOS)
        return UIImage(named:"Sample Image")
        #elseif os(macOS)
        return NSImage(named:"Sample Image")
        #endif
    },
    copyString: { _ in }
  )
}


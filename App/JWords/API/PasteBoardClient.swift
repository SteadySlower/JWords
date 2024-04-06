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

struct PasteBoardClient {
    private static let pb = PasteBoard.general
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
        #if os(iOS)
        pb.image
        #elseif os(macOS)
        let type = PasteBoard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
        return InputImageType(data: imgData)
        #endif
    },
    copyString: { string in
        #if os(iOS)
        pb.string = string
        #elseif os(macOS)
        pb.clearContents()
        pb.writeObjects([string as NSPasteboardWriting])
        #endif
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


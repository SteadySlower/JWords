//
//  PasteBoardClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/28.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import Model
import PasteBoardKit
import ComposableArchitecture
import XCTestDynamicOverlay

public struct PasteBoardClient {
    private static let pbService = PasteBoardService.shared
    public var fetchImage: () -> InputImageType?
    public var copyString: (String) -> Void
}

extension DependencyValues {
    public var pasteBoardClient: PasteBoardClient {
        get { self[PasteBoardClient.self] }
        set { self[PasteBoardClient.self] = newValue }
    }
}

extension PasteBoardClient: DependencyKey {
    public static let liveValue = PasteBoardClient(
        fetchImage: {
            pbService.fetchImage()
        },
        copyString: { text in
            pbService.copyText(text)
        }
    )
}

extension PasteBoardClient: TestDependencyKey {
    public static let previewValue = Self(
        fetchImage: {
            #if os(iOS)
            return UIImage(named:"Sample Image")
            #elseif os(macOS)
            return NSImage(named:"Sample Image")
            #endif
        },
        copyString: { _ in }
    )

    public static let testValue: PasteBoardClient = Self(
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

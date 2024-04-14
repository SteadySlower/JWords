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

public struct PasteBoardClient {
    private static let pbService = PasteBoardService.shared
    public var fetchImage: () -> InputImageType?
    public var copyString: (String) -> Void
    
    public static let liveValue = PasteBoardClient(
        fetchImage: {
            pbService.fetchImage()
        },
        copyString: { text in
            pbService.copyText(text)
        }
    )
    
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




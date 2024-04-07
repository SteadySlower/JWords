//
//  UtilClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/06.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import Model

public struct UtilClient {
    public var filterOnlyFailUnits: ([StudyUnit]) -> [StudyUnit]
    public var shuffleUnits: ([StudyUnit]) -> [StudyUnit]
    public var resizeImage: (InputImageType, CGFloat) -> InputImageType?
    
    public static let liveValue = UtilClient(
    filterOnlyFailUnits: { units in
        units
            .filter { $0.studyState != .success }
            .removeOverlapping()
            .sorted(by: { $0.createdAt < $1.createdAt })
    },
    shuffleUnits: { units in
        units.shuffled()
    },
    resizeImage: { image, deviceWidth in
        // Calculate Size
        let newWidth = deviceWidth - 10
        let newHeight = newWidth * (image.size.height / image.size.width)
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // If image is small enough, return original one
        if image.size.width < newWidth {
            return image
        }
        
        #if os(iOS)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
        #elseif os(macOS)
         let newImage = NSImage(size: newSize)

         newImage.lockFocus()

         NSGraphicsContext.current?.imageInterpolation = .high

         image.draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight),
                    from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                    operation: .sourceOver,
                    fraction: 1.0)

         newImage.unlockFocus()

         return newImage
         #endif
    }
  )
    
    private static var sampleImage: InputImageType? {
        #if os(iOS)
        return UIImage(named: "Sample Image")
        #elseif os(macOS)
        return NSImage(named: "Sample Image")
        #endif
    }
    
    public static let previewValue = Self(
    filterOnlyFailUnits: { _ in .mock },
    shuffleUnits: { _ in .mock },
    resizeImage: { _,_  in sampleImage }
  )
    
    public static let testValue: UtilClient = Self(
    filterOnlyFailUnits: { _ in .mock },
    shuffleUnits: { _ in .mock },
    resizeImage: { _,_  in sampleImage }
  )
}




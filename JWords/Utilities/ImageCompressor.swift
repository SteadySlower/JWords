//
//  ImageCompressor.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/28.
//

import Foundation
import FirebaseStorage

class ImageCompressor {
    static func compressImageToJPEG(image: InputImageType) -> Data {
        #if os(iOS)
        let jpegData = image.jpegData(compressionQuality: 0.5)!
        return jpegData
        #elseif os(macOS)
        let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        return jpegData
        #endif
    }
}

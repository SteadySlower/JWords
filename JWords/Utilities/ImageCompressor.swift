//
//  ImageCompressor.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/28.
//

import Foundation
import FirebaseStorage
#if os(macOS)
import Cocoa
#endif

protocol ImageCompressor {
    func compressImageToJPEG(image: InputImageType) throws -> Data
}

class ImageCompressorImpl: ImageCompressor {
    func compressImageToJPEG(image: InputImageType) throws -> Data {
        #if os(iOS)
        guard let jpegData = image.jpegData(compressionQuality: 0.5) else {
            throw AppError.ImageCompressor.imageToDataFail
        }
        return jpegData
        #elseif os(macOS)
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:]) else {
            throw AppError.ImageCompressor.imageToDataFail
        }
        return jpegData
        #endif
    }
}

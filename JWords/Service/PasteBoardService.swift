//
//  PasteBoardService.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

#if os(iOS)
import UIKit
typealias PasteBoard = UIPasteboard
#elseif os(macOS)
import AppKit
typealias PasteBoard = NSPasteboard
#endif

protocol PasteBoardService {
    func fetchImage() -> InputImageType?
    func fetchText() -> String?
}

class PasteBoardServiceImpl: PasteBoardService {
    
    private let pb: PasteBoard
    
    init(pb: PasteBoard = PasteBoard.general) {
        self.pb = pb
    }
    
    func fetchImage() -> InputImageType? {
        #if os(iOS)
        pb.image
        #elseif os(macOS)
        let type = PasteBoardType.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
        return InputImageType(data: imgData)
        #endif
    }
    
    func fetchText() -> String? {
        #if os(iOS)
        return pb.string
        #elseif os(macOS)
        return pb.string(forType: .string)
        #endif
    }
    
}


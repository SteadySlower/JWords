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
import Model

public class PasteBoardService {
    
    public static let shared = PasteBoardService()
    
    private let pb: PasteBoard
    
    init(pb: PasteBoard = PasteBoard.general) {
        self.pb = pb
    }
    
    public func fetchImage() -> InputImageType? {
        #if os(iOS)
        pb.image
        #elseif os(macOS)
        let type = PasteBoard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
        return InputImageType(data: imgData)
        #endif
    }
    
    public func fetchText() -> String? {
        #if os(iOS)
        return pb.string
        #elseif os(macOS)
        return pb.string(forType: .string)
        #endif
    }
    
    public func copyText(_ text: String) {
        #if os(iOS)
        pb.string = text
        #elseif os(macOS)
        pb.clearContents()
        pb.writeObjects([text as NSPasteboardWriting])
        #endif
    }
    
}


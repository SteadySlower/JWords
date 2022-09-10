//
//  WordInput.swift
//  JWords
//
//  Created by JW Moon on 2022/09/10.
//

import FirebaseFirestoreSwift
import Firebase

#if os(iOS)
import UIKit
typealias InputImageType = UIImage
#elseif os(macOS)
import Cocoa
typealias InputImageType = NSImage
#endif

protocol WordInput {
    var wordBookID: String { get }
    var meaningText: String { get }
    var meaningImage: InputImageType? { get }
    var ganaText: String { get }
    var ganaImage: InputImageType? { get }
    var kanjiText: String { get }
    var kanjiImage: InputImageType? { get }
    var studyState: StudyState { get }
    var timestamp: Timestamp { get }
    
    var meaningImageURL: String { get set }
    var ganaImageURL: String { get set }
    var kanjiImageURL: String { get set }
    
    var hasImage: Bool { get }
}

struct WordInputImpl: WordInput {
    let wordBookID: String
    let meaningText: String
    let meaningImage: InputImageType?
    let ganaText: String
    let ganaImage: InputImageType?
    let kanjiText: String
    let kanjiImage: InputImageType?
    let studyState: StudyState = .undefined
    let timestamp: Timestamp = Timestamp(date: Date())
    
    var meaningImageURL = ""
    var ganaImageURL = ""
    var kanjiImageURL = ""
    
    var hasImage: Bool {
        self.meaningImage != nil || self.ganaImage != nil || self.kanjiImage != nil
    }
}

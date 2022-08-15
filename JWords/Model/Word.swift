//
//  Word.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
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



enum StudyState: Int, Codable {
    case undefined = 0, success, fail
}

struct Word: Identifiable, Codable, Hashable{
    @DocumentID var id: String?
    var meaningText: String = ""
    var meaningImageURL: String = ""
    var ganaText: String = ""
    var ganaImageURL: String = ""
    var kanjiText: String = ""
    var kanjiImageURL: String = ""
    var studyState: StudyState
    let timestamp: Timestamp
    
    var hasImage: Bool {
        !self.meaningImageURL.isEmpty || !self.ganaImageURL.isEmpty || !self.kanjiImageURL.isEmpty
    }
}

struct WordInput {
    let meaningText: String
    let meaningImage: InputImageType?
    let ganaText: String
    let ganaImage: InputImageType?
    let kanjiText: String
    let kanjiImage: InputImageType?
    let studyState: StudyState = .undefined
    let timestamp: Timestamp = Timestamp(date: Date())
}

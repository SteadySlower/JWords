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
        return !meaningImageURL.isEmpty || !ganaImageURL.isEmpty || !kanjiImageURL.isEmpty
    }
}

struct WordInput {
    let frontText: String
    let frontImage: InputImageType?
    let backText: String
    let backImage: InputImageType?
    let studyState: StudyState = .undefined
    let timestamp: Timestamp = Timestamp(date: Date())
}

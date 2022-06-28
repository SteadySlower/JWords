//
//  Word.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import FirebaseFirestoreSwift
import Firebase
import Cocoa


enum StudyState: Int, Codable {
    case undefined = 0, success, fail
}

struct Word: Identifiable, Codable {
    @DocumentID var id: String?
    var frontText: String?
    var frontImageURL: String?
    var backText: String?
    var backImageURL: String?
    var studyState: StudyState
    let timestamp: Timestamp
}

struct WordInput {
    let frontText: String?
    let frontImage: NSImage?
    let backText: String?
    let backImage: NSImage?
    let studyState: StudyState = .undefined
    let timestamp: Timestamp = Timestamp(date: Date())
}

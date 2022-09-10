//
//  WordExamples.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/30.
//


import FirebaseFirestoreSwift
import Firebase

protocol Sample {
    var id: String? { get }
    var meaningText: String { get }
    var meaningImageURL: String { get }
    var ganaText: String { get }
    var ganaImageURL: String { get }
    var kanjiText: String { get }
    var kanjiImageURL: String { get }
    var timestamp: Timestamp { get }
    var used: Int { get }
    
    var hasImage: Bool { get }
}

struct SampleImpl: Sample, Codable, Hashable {
    @DocumentID var id: String?
    var meaningText: String = ""
    var meaningImageURL: String = ""
    var ganaText: String = ""
    var ganaImageURL: String = ""
    var kanjiText: String = ""
    var kanjiImageURL: String = ""
    let timestamp: Timestamp
    let used: Int
    
    var hasImage: Bool {
        !self.meaningImageURL.isEmpty || !self.ganaImageURL.isEmpty || !self.kanjiImageURL.isEmpty
    }
}

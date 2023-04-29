//
//  WordExamples.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/30.
//


import Foundation

//protocol Sample {
//    var id: String { get }
//    var meaningText: String { get }
//    var meaningImageURL: String { get }
//    var ganaText: String { get }
//    var ganaImageURL: String { get }
//    var kanjiText: String { get }
//    var kanjiImageURL: String { get }
//    var createdAt: Date { get }
//    var used: Int { get }
//
//    var hasImage: Bool { get }
//    var description: String { get }
//}

struct Sample: Equatable {
    let id: String
    let meaningText: String
    let meaningImageURL: String
    let ganaText: String
    let ganaImageURL: String
    let kanjiText: String
    let kanjiImageURL: String
    let createdAt: Date
    let used: Int
    
    var hasImage: Bool {
        !self.meaningImageURL.isEmpty || !self.ganaImageURL.isEmpty || !self.kanjiImageURL.isEmpty
    }
    
    var description: String {
        var result = ""
        if !self.meaningText.isEmpty {
            result += "뜻: \(self.meaningText)\t"
        }
        
        if !self.ganaText.isEmpty {
            result += "가나: \(self.ganaText)\t"
        }
        
        if !self.kanjiText.isEmpty {
            result += "한자: \(self.kanjiText)"
        }
        
        return result
    }
    
    init(id: String, dict: [String: Any]) throws {
        self.id = id
        if let meaningText = dict["meaningText"] as? String,
           let meaningImageURL = dict["meaningImageURL"] as? String,
           let ganaText = dict["ganaText"] as? String,
           let ganaImageURL = dict["ganaImageURL"] as? String,
           let kanjiText = dict["kanjiText"] as? String,
           let kanjiImageURL = dict["kanjiImageURL"] as? String,
           let createdAt = dict["createdAt"] as? Date,
           let used = dict["used"] as? Int
        {
            self.meaningText = meaningText
            self.meaningImageURL = meaningImageURL
            self.ganaText = ganaText
            self.ganaImageURL = ganaImageURL
            self.kanjiText = kanjiText
            self.kanjiImageURL = kanjiImageURL
            self.createdAt = createdAt
            self.used = used
        } else {
            throw AppError.Initializer.sampleImpl
        }
    }
    
    // initializer for mocking
    init(index: Int) {
        self.id = UUID().uuidString
        self.meaningText = "의미\(index)"
        self.meaningImageURL = ""
        self.ganaText = "가나\(index)"
        self.ganaImageURL = ""
        self.kanjiText = "한자\(index)"
        self.kanjiImageURL = "https://firebasestorage.googleapis.com:443/v0/b/jwords-935a2.appspot.com/o/card_images%2FA76BE9AC-C849-45DA-95C5-77AF39D5F096?alt=media&token=27225755-b7ab-4197-a5a1-f604b4b4f3c1"
        self.createdAt = Date()
        self.used = index
    }
}

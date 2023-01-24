//
//  WordExamples.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/30.
//


import Foundation

protocol Sample {
    var id: String { get }
    var meaningText: String { get }
    var meaningImageURL: String { get }
    var ganaText: String { get }
    var ganaImageURL: String { get }
    var kanjiText: String { get }
    var kanjiImageURL: String { get }
    var createdAt: Date { get }
    var used: Int { get }
    
    var hasImage: Bool { get }
    var description: String { get }
}

struct SampleImpl: Sample {
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
}

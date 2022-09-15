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
    var timestamp: Date { get }
    var used: Int { get }
    
    var hasImage: Bool { get }
}

struct SampleImpl: Sample {
    let id: String
    let meaningText: String
    let meaningImageURL: String
    let ganaText: String
    let ganaImageURL: String
    let kanjiText: String
    let kanjiImageURL: String
    let timestamp: Date
    let used: Int
    
    var hasImage: Bool {
        !self.meaningImageURL.isEmpty || !self.ganaImageURL.isEmpty || !self.kanjiImageURL.isEmpty
    }
    
    init(id: String, dict: [String: Any]) throws {
        self.id = id
        if let meaningText = dict["meaningText"] as? String,
           let meaningImageURL = dict["meaningImageURL"] as? String,
           let ganaText = dict["ganaText"] as? String,
           let ganaImageURL = dict["ganaImageURL"] as? String,
           let kanjiText = dict["kanjiText"] as? String,
           let kanjiImageURL = dict["kanjiImageURL"] as? String,
           let timestamp = dict["timestamp"] as? Date,
           let used = dict["used"] as? Int
        {
            self.meaningText = meaningText
            self.meaningImageURL = meaningImageURL
            self.ganaText = ganaText
            self.ganaImageURL = ganaImageURL
            self.kanjiText = kanjiText
            self.kanjiImageURL = kanjiImageURL
            self.timestamp = timestamp
            self.used = used
        } else {
            throw AppError.generic(massage: "init fail of SampleImpl of id: \(id)")
        }
    }
}

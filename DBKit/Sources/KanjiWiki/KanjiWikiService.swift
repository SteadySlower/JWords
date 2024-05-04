//
//  KanjiWikiService.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Foundation
import ErrorKit

public struct WikiKanji {
    public let kanji: String
    public let meaning: String
    public let ondoku: String
    public let kundoku: String
    
    public init(kanji: String, meaning: String, ondoku: String, kundoku: String) {
        self.kanji = kanji
        self.meaning = meaning
        self.ondoku = ondoku
        self.kundoku = kundoku
    }
}

public class KanjiWikiService {
    
    public static let shared = KanjiWikiService()
    
    private let db: [String : WikiKanji]
    
    public init() {
        let json = (try? getJSON()) ?? [:]
        var db = [String:WikiKanji]()
        
        for key in json.keys {
            guard let detail = json[key] else { continue }
            let wikiKanji = WikiKanji(
                kanji: key,
                meaning: detail["meaning"] ?? "",
                ondoku: detail["ondoku"] ?? "",
                kundoku: detail["kundoku"] ?? ""
            )
            db[key] = wikiKanji
        }
        
        self.db = db
    }
    
    public func getWikiKanji(_ kanji: String) -> WikiKanji? {
        return db[kanji]
    }
    
    public func getAllWikiKanji() -> [WikiKanji] {
        return Array(db.values)
    }
    
}

fileprivate func getJSON() throws -> [String: [String:String]] {
    guard let path = Bundle(identifier: "JWMoon.KanjiWiki")?.path(forResource: "kanjiList", ofType: "json") else {
        throw AppError.generic(massage: "Fail to Fetch JSON file from Bundle")
    }
    
    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
    
    guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: [String:String]] else {
        throw AppError.generic(massage: "Fail to Parse JSON file")
    }
    return json
}

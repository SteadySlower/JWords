//
//  Huri.swift
//  Huri
//
//  Created by JW Moon on 3/23/24.
//

import Foundation

public struct Huri: Identifiable, Equatable {
    public let id: String
    public let kanji: String
    public let gana: String
    
    public init(id: String, kanji: String, gana: String) {
        self.id = id
        self.kanji = kanji
        self.gana = gana
    }
    
    public init(id: String, huriString: String) {
        self.id = id
        if huriString.contains(where: { $0 == Character(String.huriganaFrom) }) {
            let kanjiAndGana = huriString.split(separator: Character(String.huriganaFrom))
            self.kanji = String(kanjiAndGana[0])
            self.gana = String(kanjiAndGana[1].dropLast())
        } else {
            self.kanji = ""
            self.gana = huriString
        }
    }
    
    public var toString: String {
        if !self.kanji.isEmpty {
            return "\(self.kanji)\(String.huriganaFrom)\(self.gana)\(String.huriganaTo)"
        } else {
            return self.gana
        }
    }
}

public extension Array where Element == Huri {
    mutating func update(_ huri: Huri) {
        guard let i = self.firstIndex(where: { $0.id == huri.id }) else { return }
        self[i] = huri
    }
}


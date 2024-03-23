//
//  Huri.swift
//  Huri
//
//  Created by JW Moon on 3/23/24.
//

import Foundation

struct Huri: Identifiable, Equatable {
    let id: String
    let kanji: String
    let gana: String
    
    init(id: String, kanji: String, gana: String) {
        self.id = id
        self.kanji = kanji
        self.gana = gana
    }
    
    init(id: String, huriString: String) {
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
    
    var toString: String {
        if !self.kanji.isEmpty {
            return "\(self.kanji)\(String.huriganaFrom)\(self.gana)\(String.huriganaTo)"
        } else {
            return self.gana
        }
    }
}


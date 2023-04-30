//
//  Huri.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import Foundation

struct Huri: Identifiable, Equatable {
    let id = UUID()
    let kanji: String
    let gana: String
    
    init(_ huriString: String) {
        if huriString.contains(where: { $0 == Character(String.huriganaFrom) }) {
            let kanjiAndGana = huriString.split(separator: Character(String.huriganaFrom))
            self.kanji = String(kanjiAndGana[0])
            self.gana = String(kanjiAndGana[1].dropLast())
        } else {
            self.kanji = ""
            self.gana = huriString
        }
        
    }
}

//
//  String+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/03/04.
//

import Foundation

extension String {
    
    static let whitespaceAndNewlineCharacters: [Character] = [" ", "\n", "\t"]
    
    var hasTab: Bool {
        self.contains("\t")
    }
    
    var trimmed: String {
        self.lStrip().rStrip()
    }

    private func rStrip(_ charactors: [Character] = String.whitespaceAndNewlineCharacters) -> String {
        var s = self
        guard s.contains(where: { charactors.contains($0) }) else { return self }
        while let last = s.last,
              charactors.contains(last) {
            s = String(s.dropLast())
            print("rstrip")
        }
        print(s)
        return s
        
    }
    
    private func lStrip(_ charactors: [Character] = String.whitespaceAndNewlineCharacters) -> String {
        var s = self
        guard s.contains(where: { charactors.contains($0) }) else { return self }
        while let first = s.first,
              charactors.contains(first) {
            s = String(s.dropFirst())
            print("lstrip")
        }
        print(s)
        return s
    }
    
    var isHurigana: Bool {
        self.contains { $0 == "`" }
    }
    
    var isPunctuation: Bool {
        guard self.count == 1 else { return false }
        let char = Character(self)
        if char.unicodeScalars.count == 1,
           CharacterSet.punctuationCharacters.contains(char.unicodeScalars.first!) {
            return true
        } else {
            return false
        }
    }
    
    var isKatakana: Bool {
        let katakanaCharacterSet = CharacterSet(charactersIn: "\u{30A0}"..."\u{30FF}")
        if self.unicodeScalars.allSatisfy({ katakanaCharacterSet.contains($0) }) {
            return true
        } else {
            return false
        }
    }
    
    var isRomaji: Bool {
        let letters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let range = self.rangeOfCharacter(from: letters.inverted)
        return range == nil
    }
    
    var isHanGeul: Bool {
        let letters = CharacterSet(charactersIn: "가-힣")
        let range = self.rangeOfCharacter(from: letters.inverted)
        return range == nil
    }
}

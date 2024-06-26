//
//  Character+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/04/29.
//

public extension Character {
    var isKanji: Bool {
        if let scalar = self.unicodeScalars.first,
           scalar.properties.isUnifiedIdeograph {
            return true
        } else {
            return false
        }
    }
}

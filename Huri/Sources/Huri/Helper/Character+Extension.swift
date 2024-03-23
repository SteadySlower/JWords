//
//  Character+Extension.swift
//  Huri
//
//  Created by JW Moon on 2023/04/29.
//

extension Character {
    var isKanji: Bool {
        if let scalar = self.unicodeScalars.first,
           scalar.properties.isUnifiedIdeograph {
            return true
        } else {
            return false
        }
    }
}

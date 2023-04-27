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

    func rStrip(_ charactors: [Character] = String.whitespaceAndNewlineCharacters) -> String {
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
    
    func lStrip(_ charactors: [Character] = String.whitespaceAndNewlineCharacters) -> String {
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
}

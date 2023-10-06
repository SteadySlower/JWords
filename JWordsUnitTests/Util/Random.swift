//
//  Random.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2022/09/12.
//

import Foundation

class Random {
    
    static var string: String {
        let length = (1...100).randomElement() ?? 10
        let alphabets = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var result = ""
        
        for _ in 0..<length {
            let randomAlphabet = alphabets.randomElement() ?? "a"
            result += String(randomAlphabet)
        }
        
        return result
    }
    
    static var dateWithinYear: Date {
        let now = Date().timeIntervalSince1970
        let gap = Double((0..<31536000).randomElement() ?? 0)
        return Date(timeIntervalSince1970: now - gap)
    }
    
    static var bool: Bool {
        Bool.random()
    }
    
    static func int(from: Int, to: Int) -> Int {
        (from...to).randomElement() ?? from
    }
    
    
}

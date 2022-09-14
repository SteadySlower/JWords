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
    
}

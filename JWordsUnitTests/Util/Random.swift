//
//  Random.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2022/09/12.
//

import Foundation

class Random {
    
    static var string: String {
        let length = (1...100).randomElement()!
        let alphabets = "abcdefghijklmnopqrstuvwxyz"
        var result = ""
        
        for _ in 0..<length {
            result += alphabets.randomElement()!
        }
        
        return result
    }
    
}

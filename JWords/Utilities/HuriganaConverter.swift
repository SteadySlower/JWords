//
//  HuriganaConverter.swift
//  JWords
//
//  Created by JW Moon on 2023/04/29.
//

import Foundation

class HuriganaConverter {
    
    static let shared = HuriganaConverter()
    
    func convert(_ input: String) -> String {
        var result = ""
        
        // 주어진 String의 공백과 \n을 모두 없앤다.
        let trimmed: String = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // CFStringTokenizer 객체를 만든다.
        let tokenizer: CFStringTokenizer =
            CFStringTokenizerCreate(kCFAllocatorDefault, // 메모리 할당하는 객체
                                    trimmed as CFString, // token으로 쪼갤 CFString
                                    CFRangeMake(0, trimmed.utf16.count), // token으로 쪼갤 CFString의 range (= 전체)
                                    kCFStringTokenizerUnitWordBoundary, // 단어 단위로 쪼갠다
                                    Locale(identifier: "ja") as CFLocale) // 언어 설정 (일본어)
        
        while !CFStringTokenizerAdvanceToNextToken(tokenizer).isEmpty {
            
            let tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let tokenStart = trimmed.index(trimmed.startIndex, offsetBy: tokenRange.location)
            let tokenEnd = trimmed.index(tokenStart, offsetBy: tokenRange.length)
            let token = String(trimmed[tokenStart..<tokenEnd])
            
            let gana = tokenizer.letter(to: kCFStringTransformLatinHiragana)
            
            if token == gana || token.isPunctuation || token == " " || gana == "" {
                result.append(token)
            } else {
                result.append("\(token)[\(gana)]")
            }
        }
        
        return result
    }
    
}


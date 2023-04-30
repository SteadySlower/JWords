//
//  HuriganaConverter.swift
//  JWords
//
//  Created by JW Moon on 2023/04/29.
//

import Foundation

extension String {
    static let huriganaFrom = "⌜"
    static let huriganaTo = "⌟"
}

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
        
        // 하나씩 토큰을 넘기면서
        while !CFStringTokenizerAdvanceToNextToken(tokenizer).isEmpty {
            
            // 원래 토큰에 해당하는 String을 잘라서 가져온다.
            let tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let tokenStart = trimmed.index(trimmed.startIndex, offsetBy: tokenRange.location)
            let tokenEnd = trimmed.index(tokenStart, offsetBy: tokenRange.length)
            let token = String(trimmed[tokenStart..<tokenEnd])
            
            // 해당 토큰을 가나로 변환
            let gana = tokenizer.letter(to: kCFStringTransformLatinHiragana)
            
            // 토큰이 가나이거나, 구두점이거나, 빈칸이면 그냥 더하기
            if token == gana
                || token.isPunctuation
                || token.isKatakana
                || token == " "
                || gana == ""
            {
                result.append(token)
            // 한자면 []안에 더하기
            } else {
                let trimmed = trimHuri(token, gana)
                result.append("\(trimmed.0)\(String.huriganaFrom)\(trimmed.1)\(String.huriganaTo)`\(trimmed.2)")
            }
            
            result.append("`")
        }
        
        return result
    }
    
}

fileprivate func trimHuri(_ token: String, _ gana: String) -> (String, String, String) {
    var gana = gana
    var token = token
    var tail = ""
    while let gLast = gana.last,
          let tLast = token.last,
          gLast == tLast {
        tail = "\(gana.removeLast())\(tail)"
        token = String(token.dropLast())
    }
    return (token, gana, tail)
}


//
//  HuriganaConverter.swift
//  
//
//  Created by JW Moon on 3/23/24.
//

import Foundation

public class HuriganaConverter {
    
    public init() {}
    
    public func convert(_ input: String) -> String {
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
                || token.isRomaji
            {
                result.append(token)
            // 한자면 []안에 더하기
            } else {
                let trimmed = trimHuri(token, gana)
                if !trimmed.2.isEmpty {
                    result.append("\(trimmed.0)\(String.huriganaFrom)\(trimmed.1)\(String.huriganaTo)`\(trimmed.2)")
                } else {
                    result.append("\(trimmed.0)\(String.huriganaFrom)\(trimmed.1)\(String.huriganaTo)")
                }
            }
            
            result.append(.betweenHurigana)
        }
        
        return result
    }
    
    public func convertToHuris(from hurigana: String) -> [Huri] {
        return hurigana
            .split(separator: String.betweenHurigana)
            .enumerated()
            .map { (index, huriString) in
                Huri(id: "\(index)\(huriString)", huriString: String(huriString))
            }
    }
    
    public func extractKanjis(from hurigana: String) -> [String] {
        var result = [String]()
        let huris = hurigana
            .split(separator: String.betweenHurigana)
            .enumerated()
            .map { (index, huriString) in
                Huri(id: "\(index)\(huriString)", huriString: String(huriString))
            }
        
        for huri in huris {
            for kanji in huri.kanji {
                guard kanji.isKanji else { continue }
                result.append(String(kanji))
            }
        }
        
        return result.filter { !$0.isEmpty }
    }
    
    public func huriToKanjiText(from hurigana: String) -> String {
        hurigana
            .split(separator: String.betweenHurigana)
            .enumerated()
            .map { (index, huriString) in
                Huri(id: "\(index)\(huriString)", huriString: String(huriString))
            }
            .map { $0.kanji.isEmpty ? $0.gana : $0.kanji }
            .reduce("", +)
    }
    
    public func hurisToHurigana(huris: [Huri]) -> String {
        huris.map { $0.toString + String.betweenHurigana }.joined()
    }
    
    private func trimHuri(_ token: String, _ gana: String) -> (String, String, String) {
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
}

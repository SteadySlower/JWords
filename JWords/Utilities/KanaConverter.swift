//
//  KanaConverter.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/10/12.
//

// source code: https://gist.github.com/WorldDownTown/0343b4f31be1117abb2e2213b707c99c

import Foundation

// CFStringTokenizer: 연속된 String을 Token (단어, 문장) 단위로 쪼개주는 객체
extension CFStringTokenizer {
    
    // CFStringTokenizer 안에 있는 CFString을 가지고 string으로 바꾸어주는 computed property
        // kCFStringTransformLatinHiragana과 kCFStringTransformLatinKatakana는 CFString 타입이지만 실제로 데이터를 담고 있는 것은 아니고
        // 라틴을 히라가나로 바꾸는 방식을 나타내는 identifier로의 역할을 하는 글로벌 변수임 (https://developer.apple.com/documentation/corefoundation/kcfstringtransformlatinhiragana)
    var hiragana: String { string(to: kCFStringTransformLatinHiragana) }
    var katakana: String { string(to: kCFStringTransformLatinKatakana) }
    
    // CFStringTokenizer안에 있는 토큰을 하나하나 풀어서 gana로 변경한 다음에 하나의 string으로 합쳐서 리턴함.
    private func string(to transform: CFString) -> String {
        var output: String = ""
        // 다음 토큰으로 이동해서 gana letter로 바꾸고 output에 더해준다.
        while !CFStringTokenizerAdvanceToNextToken(self).isEmpty {
            output.append(letter(to: transform))
        }
        return output
    }

    // 토큰 하나를 gana string으로 하나로 바꾸어 주는 함수
    func letter(to transform: CFString) -> String {
        
        // 현재 Token을 복사해오는데 Lantin Transction으로 가져온다. (여기서 한자가 Latin Transcription으로 바뀜)
            // 그리고 나서 NSString -> NSMutableString으로 바꾼다 (Latin을 gana로 바꾸기 위해서 mutable로)
        let mutableString: NSMutableString =
            CFStringTokenizerCopyCurrentTokenAttribute(self, kCFStringTokenizerAttributeLatinTranscription)
                .flatMap { $0 as? NSString }
                .map { $0.mutableCopy() }
                .flatMap { $0 as? NSMutableString } ?? NSMutableString()
        
        // CFMutableString을 identifier에 맞게 변환해준다. (여기서는 latin을 gana로)
            // mutableString 변수에 할당해줌
        CFStringTransform(mutableString, nil, transform, false)
        
        // NSMutableString을 다시 String으로 바꾸어서 리턴한다.
        return mutableString as String
    }
}

private enum Kana { case hiragana, katakana }

private func convert(_ input: String, to kana: Kana = .hiragana) -> String {
    // 주어진 String의 공백과 \n을 모두 없앤다.
    let trimmed: String = input.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // CFStringTokenizer 객체를 만든다.
    let tokenizer: CFStringTokenizer =
        CFStringTokenizerCreate(kCFAllocatorDefault, // 메모리 할당하는 객체
                                trimmed as CFString, // token으로 쪼갤 CFString
                                CFRangeMake(0, trimmed.utf16.count), // token으로 쪼갤 CFString의 range (= 전체)
                                kCFStringTokenizerUnitWordBoundary, // 단어 단위로 쪼갠다
                                Locale(identifier: "ja") as CFLocale) // 언어 설정 (일본어)
    
    // extension으로 구현한 computed property를 통해서 히라가나나 카타카나를 리턴한다.
    switch kana {
    case .hiragana: return tokenizer.hiragana
    case .katakana: return tokenizer.katakana
    }
}

extension String {
    var hiragana: String { convert(self, to: .hiragana) }
    var katakana: String { convert(self, to: .katakana) }
}

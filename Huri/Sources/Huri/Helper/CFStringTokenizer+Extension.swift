//
//  CFStringTokenizer+Extension.swift
//  Huri
//
//  Created by JW Moon on 3/23/24.
//

import Foundation

// CFStringTokenizer: 연속된 String을 Token (단어, 문장) 단위로 쪼개주는 객체
extension CFStringTokenizer {
    
    // CFStringTokenizer 안에 있는 CFString을 가지고 string으로 바꾸어주는 computed property
        // kCFStringTransformLatinHiragana과 kCFStringTransformLatinKatakana는 CFString 타입이지만 실제로 데이터를 담고 있는 것은 아니고
        // 라틴을 히라가나로 바꾸는 방식을 나타내는 identifier로의 역할을 하는 글로벌 변수임.
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

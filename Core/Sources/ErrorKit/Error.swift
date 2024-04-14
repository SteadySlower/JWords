//
//  Error.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

public enum AppError: Error, Equatable {
    case generic(massage: String)
    case noMatchingUnit(id: String)
    case coreData
    case cloudKit
    case ocr
    
    case unknown
    
    // error when add study unit
    case notConvertedToHuri
    case KanjiTooLong
    
    // error when add study set
    case emptyTitle
    
    public var errorMessage: String {
        switch self {
        case .KanjiTooLong:
            return "한자는 1글자 이상 저장할 수 없습니다."
        case .notConvertedToHuri:
            return "후리가나로 변환해야 저장할 수 있습니다."
        case .emptyTitle:
            return "제목이 비어 있습니다."
        default:
            return "알 수 없는 에러입니다."
        }
    }
}


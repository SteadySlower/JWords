//
//  Error.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

import ComposableArchitecture

enum AppError: Error, Equatable {
    case generic(massage: String)
    case noMatchingWord(id: String)
    
    // error when add study unit
    case notConvertedToHuri
    case KanjiTooLong
    
    case imageCompressor(error: AppError.ImageCompressor)
    case imageUploader(error: AppError.ImageUploader)
    case wordService(error: AppError.WordService)
    case wordBookService(error: AppError.WordBookService)
    case initializer(error: AppError.Initializer)
    case firebase(error: AppError.Firebase)
    
    var errorMessage: String {
        switch self {
        case .KanjiTooLong:
            return "한자는 1글자 이상 저장할 수 없습니다."
        case .notConvertedToHuri:
            return "후리가나로 변환해야 저장할 수 있습니다."
        default:
            return "알 수 없는 에러입니다."
        }
    }
    
    func simpleAlert<T>(action: T.Type) -> AlertState<T> {
        return AlertState<T> {
          TextState("에러")
        } actions: {
          ButtonState(role: .cancel) {
            TextState("확인")
          }
        } message: {
            TextState(self.errorMessage)
        }
    }
}

// MARK: SubErrors

extension AppError {
    
    enum ImageCompressor: Error {
        case imageToDataFail
        
        var message: String {
            switch self {
            case .imageToDataFail:
                return "\(String(describing: self)): Failed to compress image into data"
            }
        }
    }
    enum ImageUploader: Error {
        case imageURLNil
        case failToUploadImage
        case failToDownloadImageURL
        
        var message: String {
            switch self {
            case .imageURLNil:
                return "\(String(describing: self)): No URL Found"
            case .failToUploadImage:
                return "\(String(describing: self)): Failed to upload image"
            case .failToDownloadImageURL:
                return "\(String(describing: self)): Failed to download image URL"
            }
        }
    }
    enum WordService: Error {
        case noWordImageURL
        
        var message: String {
            switch self {
            case .noWordImageURL:
                return "\(String(describing: self)): No word image URL Found"
            }
        }
    }
    
    enum WordBookService: Error {
        case noWordBooks
        
        var message: String {
            switch self {
            case .noWordBooks:
                return "\(String(describing: self)): wordBooks is nil"
            }
        }
    }
    
    enum Initializer: String, Error {
        case wordBookImpl
        case wordImpl
        case sampleImpl
        case todayBookImpl
        
        var message: String {
            return "\(String(describing: self)): Failed to init \(self.rawValue)"
        }
    }
    
    enum Firebase: Error {
        case noTimestamp
        case noDocument
        
        var message: String {
            switch self {
            case .noTimestamp:
                return "\(String(describing: self)): No timestamp in firebase document"
            case .noDocument:
                return "\(String(describing: self)): No document in firebase snapshot"
            }
        }
    }
    
}

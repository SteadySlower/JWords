//
//  Error.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

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

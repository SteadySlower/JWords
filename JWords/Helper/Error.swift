//
//  Error.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

enum AppError: Error {
    case generic(massage: String)
    enum Utilities: Error {
        case imageToDataFail
        
        var message: String {
            switch self {
            case .imageToDataFail:
                return "Failed to compress image into data"
            }
        }
    }
}

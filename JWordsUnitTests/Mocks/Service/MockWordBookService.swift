//
//  MockWordBookService.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2022/09/10.
//

@testable import JWords

class MockWordBookService {
    var saveBookError: Error?
    var getWordBooksSuccess: [WordBook]?
    var checkIfOverlapSuccess: Bool?
    var closeWordBookError: Error?
}

extension MockWordBookService: WordBookService {
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        if let saveBookError = saveBookError {
            completionHandler(error)
            return
        }
        completionHandler(nil)
    }
    
    func getWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        guard let getWordBooksSuccess = getWordBooksSuccess else {
            let error = AppError.generic(massage: "Mock Error from MockWordBookService.getWordBooks")
            completionHandler(nil, error)
            return
        }
        completionHandler(getWordBooksSuccess, nil)
    }
    
    func checkIfOverlap(in wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>) {
        guard let checkIfOverlapSuccess = checkIfOverlapSuccess else {
            let error = AppError.generic(massage: "Mock Error from MockWordBookService.checkIfOverlap")
            completionHandler(nil, error)
            return
        }
        completionHandler(checkIfOverlapSuccess, nil)
    }
    
    func closeWordBook(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData) {
        if let closeWordBookError = closeWordBookError {
            completionHandler(closeWordBookError)
            return
        }
        completionHandler(nil)
    }
}

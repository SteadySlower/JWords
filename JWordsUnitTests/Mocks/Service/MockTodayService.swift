//
//  MockTodayService.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/27.
//

@testable import JWords

class MockTodayService {
    var updateStudyBookError: Error?
    var getStudyBooksSuccess: [String]?
    var updateReviewBooksError: Error?
    var getReviewBooksSuccess: [String]?
    var getTodaysBooksSuccess: ([String], [String])?
}

extension MockTodayService: TodayService {
    func updateStudyBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
        if let updateStudyBookError = updateStudyBookError {
            completionHandler(updateStudyBookError)
            return
        }
        completionHandler(nil)
    }
    
    func getStudyBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
        guard let getStudyBooksSuccess = getStudyBooksSuccess else {
            let error = AppError.generic(massage: "Mock Error from MockTodayService.getStudyBooks")
            completionHandler(nil, error)
            return
        }
        completionHandler(getStudyBooksSuccess, nil)
    }
    
    func updateReviewBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
        if let updateReviewBooksError = updateReviewBooksError {
            completionHandler(updateReviewBooksError)
            return
        }
        completionHandler(nil)
    }
    
    func getReviewBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
        guard let getReviewBooksSuccess = getReviewBooksSuccess else {
            let error = AppError.generic(massage: "Mock Error from MockTodayService.getReviewBooks")
            completionHandler(nil, error)
            return
        }
        completionHandler(getReviewBooksSuccess, nil)
    }
    
    func getTodaysBooks(_ wordBooks: [WordBook], _ completionHandler: @escaping CompletionWithData<([String], [String])>) {
        guard let getTodaysBooksSuccess = getTodaysBooksSuccess else {
            let error = AppError.generic(massage: "Mock Error from MockTodayService.getTodaysBooks")
            completionHandler(nil, error)
            return
        }
        completionHandler(getTodaysBooksSuccess, nil)
    }
    
    func updateReviewed(_ id: String) {
        return
    }
    
}

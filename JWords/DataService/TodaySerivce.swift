//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import Foundation

protocol TodayService {
    func updateStudyBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData)
    func getStudyBooks(_ completionHandler: @escaping CompletionWithData<[String]>)
    func updateReviewBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData)
    func getReviewBooks(_ completionHandler: @escaping CompletionWithData<[String]>)
    func getTodaysBooks(_ wordBooks: [WordBook], _ completionHandler: @escaping CompletionWithData<([String], [String])>)
    func updateReviewed(_ id: String)
}

final class TodayServiceImpl: TodayService {
    
    // DB
    let db: Database
    
    // Initializer
    init(database: Database) {
        self.db = database
    }
    
    // functions
    
    func updateStudyBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
    }
    
    func getStudyBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
    }
    
    func updateReviewBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
    }
    
    func getReviewBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
    }
    
    func getTodaysBooks(_ wordBooks: [WordBook], _ completionHandler: @escaping CompletionWithData<([String], [String])>) {
        var studyID = [String]()
        var reviewID = [String]()
        for wordBook in wordBooks {
            if wordBook.schedule == .study {
                studyID.append(wordBook.id)
            } else if wordBook.schedule == .review {
                reviewID.append(wordBook.id)
            }
        }
        let todayBooks = TodayBooksImpl(studyIDs: studyID, reviewIDs: reviewID, reviewedIDs: [], createdAt: Date())
        
        db.updateTodayBooks(todayBooks) { error in
            completionHandler(nil, nil)
        }
    }
    
    func updateReviewed(_ id: String) {
    }
}

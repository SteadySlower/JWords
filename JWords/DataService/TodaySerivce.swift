//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import Foundation

protocol TodayService {
    func autoUpdateTodayBooks(_ wordBooks: [WordBook], _ completionHandler: @escaping CompletionWithoutData)
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodayBooks>)
    func updateTodayBooks(_ todayBooks: TodayBooks, _ completionHandler: @escaping CompletionWithoutData)
}

final class TodayServiceImpl: TodayService {
    
    // DB
    let db: Database
    
    // Initializer
    init(database: Database) {
        self.db = database
    }
    
    // functions
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodayBooks>) {
        db.getTodayBooks { todayBooks, error in
            if error != nil {
                completionHandler(nil, error)
                return
            }
            completionHandler(todayBooks, nil)
        }
    }
    
    func autoUpdateTodayBooks(_ wordBooks: [WordBook], _ completionHandler: @escaping CompletionWithoutData) {
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
            completionHandler(error)
        }
    }
    
    func updateTodayBooks(_ todayBooks: TodayBooks, _ completionHandler: @escaping CompletionWithoutData) {
        db.updateTodayBooks(todayBooks, completionHandler)
    }
}

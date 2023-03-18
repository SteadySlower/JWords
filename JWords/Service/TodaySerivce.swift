//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import Foundation

protocol TodayService {
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodayBooks>)
    func autoUpdateTodayBooks(_ wordBooks: [WordBook], _ completionHandler: @escaping CompletionWithoutData)
    func updateTodayBooks(_ todayBooks: TodayBooks, _ completionHandler: @escaping CompletionWithoutData)
    func updateReviewed(_ reviewedID: String, _ completionHandler: @escaping CompletionWithoutData)
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
    
    func updateReviewed(_ reviewedID: String, _ completionHandler: @escaping CompletionWithoutData) {
        getTodayBooks { [weak self] todayBooks, error in
            guard let self = self else { return }
            if let error = error {
                completionHandler(error)
                return
            }
            // TODO: Handle Error
            guard let todayBooks = todayBooks else { return }
            let newReviewedIDs = todayBooks.reviewedIDs + [reviewedID]
            let newTodayBooks = TodayBooksImpl(studyIDs: todayBooks.studyIDs, reviewIDs: todayBooks.reviewIDs, reviewedIDs: newReviewedIDs, createdAt: todayBooks.createdAt)
            self.updateTodayBooks(newTodayBooks) { error in
                completionHandler(error)
            }
        }
    }
}

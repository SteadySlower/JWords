//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

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
    
    private var studyID = [String]()
    private var reviewID = [String]()
    private var reviewedID = [String]()
    
    // functions
    
    func updateStudyBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
        self.studyID = idArray
        completionHandler(nil)
    }
    
    func getStudyBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
        completionHandler(studyID, nil)
    }
    
    func updateReviewBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
        self.reviewID = idArray
        completionHandler(nil)
    }
    
    func getReviewBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
        let filtered = reviewID.filter { !reviewedID.contains($0) }
        completionHandler(filtered, nil)
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
        self.studyID = studyID
        self.reviewID = reviewID
        self.reviewedID = [String]()
        completionHandler((studyID, reviewID), nil)
    }
    
    func updateReviewed(_ id: String) {
        reviewedID.append(id)
    }
}

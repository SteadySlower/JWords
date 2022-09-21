//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

protocol TodayService {
    func updateStudyBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData)
    func getStudyBooks(_ completionHandler: @escaping CompletionWithData<[String]>)
}

class TodayServiceImpl: TodayService {
    private var studyID = [String]()
    private var reviewID = [String]()
    
    func updateStudyBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
        self.studyID = idArray
        completionHandler(nil)
    }
    
    func getStudyBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
        completionHandler(studyID, nil)
    }
}

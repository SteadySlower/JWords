//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

protocol TodayService {
    func updateTodayBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData)
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<[String]>)
}

class TodayServiceImpl: TodayService {
    private var selectedID = [String]()
    
    func updateTodayBooks(_ idArray: [String], completionHandler: @escaping CompletionWithoutData) {
        self.selectedID = idArray
        completionHandler(nil)
    }
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<[String]>) {
        completionHandler(selectedID, nil)
    }
}

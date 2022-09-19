//
//  TodaySerivce.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

protocol TodayService {
    func addTodayBooks(_ wordBook: WordBook, completionHandler: @escaping CompletionWithoutData)
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<[WordBook]>)
}

class TodayServiceImpl: TodayService {
    func addTodayBooks(_ wordBook: WordBook, completionHandler: @escaping CompletionWithoutData) {
        return
    }
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<[WordBook]>) {
        return
    }
}

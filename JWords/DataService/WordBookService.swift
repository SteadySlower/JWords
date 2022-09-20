//
//  WordBookService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

protocol WordBookService {
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData)
    func getWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>)
    func checkIfOverlap(in wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>)
    func moveWords(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData)
}

class WordBookServiceImpl: WordBookService {
    
    let db: Database
    let wordService: WordService
    
    init(database: Database, wordService: WordService) {
        self.db = database
        self.wordService = wordService
    }
    
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        db.insertWordBook(title: title, completionHandler: completionHandler)
    }
    
    func getWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        db.fetchWordBooks(completionHandler: completionHandler)
    }
    
    func checkIfOverlap(in wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>) {
        db.checkIfOverlap(wordBook: wordBook, meaningText: meaningText, completionHandler: completionHandler)
    }
    
    // TODO: 복습으로 체크하는 기능 생기면 복습으로 체크하는 함수로 바꾸고 닫기 함수는 따로 만들기
    func moveWords(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData) {
        if let destination = destination {
            wordService.moveWords(toMove, to: destination) { error in
                completionHandler(error)
//                if let error = error { completionHandler(error) }
//                self?.db.closeWordBook(of: toClose, completionHandler: completionHandler)
            }
        } else {
            completionHandler(nil)
//            db.closeWordBook(of: toClose, completionHandler: completionHandler)
        }
    }
    
}

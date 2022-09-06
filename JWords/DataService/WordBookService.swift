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
    func closeWordBook(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData)
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
    
    func closeWordBook(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData) {
        if let destination = destination {
            wordService.copyWords(toMove, to: destination) { [weak self] error in
                if let error = error { completionHandler(error) }
                self?.db.closeWordBook(of: toClose, completionHandler: completionHandler)
            }
        } else {
            db.closeWordBook(of: toClose, completionHandler: completionHandler)
        }
    }
    
}

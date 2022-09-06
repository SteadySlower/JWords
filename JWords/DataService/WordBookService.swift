//
//  WordBookService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

protocol WordBookService {
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData)
    func getWordBooks(completionHandler: @escaping CompletionWithData<WordBook>)

    func checkIfOverlap(word: Word, completionHandler: @escaping CompletionWithData<Bool>)
    func closeWordBook(of toClose: WordBook, to destination: WordBook, toMove: [Word], completionHandler: @escaping CompletionWithoutData)
}

class WordBookServiceImpl: WordBookService {
    
    let db: WordbookDatabase
    
    init(database: WordbookDatabase) {
        self.db = database
    }
    
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        db.insertWordBook(title: title, completionHandler: completionHandler)
    }
    
    func checkIfOverlap(word: Word, completionHandler: @escaping CompletionWithData<Bool>) {
        db.checkIfOverlap(word: word, completionHandler: completionHandler)
    }
    
    func getWordBooks(completionHandler: @escaping CompletionWithData<WordBook>) {
        <#code#>
    }
    
    func closeWordBook(of toClose: WordBook, to destination: WordBook, toMove: [Word], completionHandler: @escaping CompletionWithoutData) {
        <#code#>
    }
    
}

//
//  WordBookService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

protocol WordBookService {
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData)
    func getWordBooks(completionHandler: @escaping CompletionWithData<WordBook>)
    func closeWordBook(of id: String, to: String?, toMoveWords: [Word], completionHandler: @escaping CompletionWithoutData)
}

class WordBookServiceImpl: WordBookService {
    
    let db: WordbookDatabase
    
    init(database: WordbookDatabase) {
        self.db = database
    }
    
    func saveBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        db.insertWordBook(title: title, completionHandler: completionHandler)
    }
    
    func getWordBooks(completionHandler: @escaping CompletionWithData<WordBook>) {
        <#code#>
    }
    
    func closeWordBook(of id: String, to: String?, toMoveWords: [Word], completionHandler: @escaping CompletionWithoutData) {
        <#code#>
    }
    
}

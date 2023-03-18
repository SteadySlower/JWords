//
//  WordBookService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

protocol WordBookService {
    func saveBook(title: String, preferredFrontType: FrontType, completionHandler: @escaping CompletionWithoutData)
    func getWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>)
    func checkIfOverlap(in wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>)
    func moveWords(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData)
    func closeWordBook(_ wordBook: WordBook, completionHandler: @escaping CompletionWithoutData)
    func countWords(in wordBook: WordBook, completionHandler: @escaping CompletionWithData<Int>)
}

class WordBookServiceImpl: WordBookService {
    let db: Database
    let wordService: WordService
    
    init(database: Database, wordService: WordService) {
        self.db = database
        self.wordService = wordService
    }
    
    func saveBook(title: String, preferredFrontType: FrontType, completionHandler: @escaping CompletionWithoutData) {
        db.insertWordBook(title: title, preferredFrontType: preferredFrontType, completionHandler: completionHandler)
    }
    
    func getWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        db.fetchWordBooks { wordBook, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let wordBook = wordBook else {
                let error = AppError.WordBookService.noWordBooks
                print(error.message)
                completionHandler(nil, error)
                return
            }
            
            let filtered = wordBook.filter { $0.closed != true }
            completionHandler(filtered, nil)
        }
    }
    
    func checkIfOverlap(in wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>) {
        db.checkIfOverlap(wordBook: wordBook, meaningText: meaningText, completionHandler: completionHandler)
    }
    
    func moveWords(of toClose: WordBook, to destination: WordBook?, toMove: [Word], completionHandler: @escaping CompletionWithoutData) {
        if let destination = destination {
            wordService.moveWords(toMove, to: destination) { error in
                completionHandler(error)
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func closeWordBook(_ wordBook: WordBook, completionHandler: @escaping CompletionWithoutData) {
        db.closeWordBook(of: wordBook, completionHandler: completionHandler)
    }
    
    func countWords(in wordBook: WordBook, completionHandler: @escaping CompletionWithData<Int>) {
        db.fetchWords(wordBook) { words, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let words = words else {
                let error = AppError.generic(massage: "Nil Words in word book")
                print(error.localizedDescription)
                completionHandler(nil, error)
                return
            }
            completionHandler(words.count, nil)
        }
    }

}

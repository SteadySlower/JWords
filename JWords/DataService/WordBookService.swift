//
//  WordBookService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

protocol WordBookServiceProtocol {
    func getWordBooks(completionHandler: CompletionWithData<WordBook>)
    func closeWordBook(of id: String, to: String?, toMoveWords: [Word], completionHandler: CompletionWithoutData)
}

class WordBookService {
    
}

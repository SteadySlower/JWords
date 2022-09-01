//
//  WordDatabase.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

import Firebase

protocol WordDatabase {
    static func getWordBooks(completionHandler: @escaping ([WordBook]?, Error?) -> Void)
}

extension Firestore: WordDatabase {
    static func getWordBooks(completionHandler: @escaping ([WordBook]?, Error?) -> Void) {
        Constants.Collections.wordBooks.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            let wordBooks = documents.compactMap({ try? $0.data(as: WordBook.self) })
            completionHandler(wordBooks, nil)
        }
    }
}

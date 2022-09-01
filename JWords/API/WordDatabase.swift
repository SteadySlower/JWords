//
//  WordDatabase.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

import Firebase

protocol WordDatabase {
    func fetchWordBooks(completionHandler: @escaping ([WordBook]?, Error?) -> Void)
    func fetchWords(wordBookID id: String, completionHandler: @escaping ([Word]?, Error?) -> Void)
}

// Firebase에 직접 extension으로 만들어도 되지만 Firebase를 한단계 감싼 class를 만들었음.
final class FirestoreWordDB: WordDatabase {
    
    // Firestore singleton
    let firestore = Firestore.firestore()
    
    // CollectionReferences
    private lazy var wordBookRef = {
        firestore
        .collection("develop")
        .document("data")
        .collection("wordBooks")
    }()
            
    private func wordRef(of bookID: String) -> CollectionReference {
        firestore
        .collection("develop")
        .document("data")
        .collection("wordBooks")
        .document(bookID)
        .collection("words")
    }
    
    private lazy var exampleRef = {
        firestore
        .collection("develop")
        .document("data")
        .collection("examples")
    }()
    
    // API functions
    func fetchWordBooks(completionHandler: @escaping ([WordBook]?, Error?) -> Void) {
        wordBookRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            let wordBooks = documents.compactMap({ try? $0.data(as: WordBook.self) })
            completionHandler(wordBooks, nil)
        }
    }
    
    func fetchWords(wordBookID id: String, completionHandler: @escaping ([Word]?, Error?) -> Void) {
        wordRef(of: id).order(by: "timestamp").getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            let words = documents.compactMap({ try? $0.data(as: Word.self) })
            completionHandler(words, nil)
        }
    }
}

//
//  Database.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

import Firebase

protocol Database {
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>)
    func fetchWords(wordBookID id: String, completionHandler: @escaping CompletionWithData<[Word]>)
    func insertWordBook(title: String, completionHandler: @escaping CompletionWithoutData)
    func insertWord(wordInput: WordInput, to wordBookID: String, completionHandler: @escaping CompletionWithoutData)
}

// Firebase에 직접 extension으로 만들어도 되지만 Firebase를 한단계 감싼 class를 만들었음.
final class FirestoreDB {
    
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
}


// MARK: API Functions
extension FirestoreDB: Database {
   
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        wordBookRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            let wordBooks = documents.compactMap({ try? $0.data(as: WordBook.self) })
            completionHandler(wordBooks, nil)
        }
    }
    
    func fetchWords(wordBookID id: String, completionHandler: @escaping CompletionWithData<[Word]>) {
        wordRef(of: id).order(by: "timestamp").getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            var words = documents.compactMap({ try? $0.data(as: Word.self) })
            for i in 0..<words.count {
                words[i].wordBookID = id
            }
            completionHandler(words, nil)
        }
    }
    
    func insertWordBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = [
            "title": title,
            "timestamp": Timestamp(date: Date())]
        wordBookRef.addDocument(data: data, completion: completionHandler)
    }
    
    func insertWord(wordInput: WordInput, to wordBookID: String, completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                    "meaningText": wordInput.meaningText,
                                    "meaningImageURL": wordInput.meaningImageURL,
                                    "ganaText": wordInput.ganaText,
                                    "ganaImageURL": wordInput.ganaImageURL,
                                    "kanjiText": wordInput.kanjiText,
                                    "kanjiImageURL": wordInput.kanjiImageURL,
                                    "studyState": wordInput.studyState.rawValue]
        
        wordRef(of: wordBookID).addDocument(data: data, completion: completionHandler)
    }
}

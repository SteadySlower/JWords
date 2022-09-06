//
//  Database.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

import Firebase

protocol WordbookDatabase {
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>)
    func insertWordBook(title: String, completionHandler: @escaping CompletionWithoutData)
    func checkIfOverlap(word: Word, completionHandler: @escaping CompletionWithData<Bool>)
    func closeWordBook(of toClose: WordBook, completionHandler: @escaping CompletionWithoutData)
}

protocol WordDatabase {
    func fetchWords(_ wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>)
    func insertWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData)
    func copyWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: CompletionWithoutData)
}

protocol SampleDatabase {
    func insertSample(_ wordInput: WordInput)
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
    
    private lazy var sampleRef = {
        firestore
        .collection("develop")
        .document("data")
        .collection("examples")
    }()
}


// MARK: WordbookDatabase
extension FirestoreDB: WordbookDatabase {
    
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
    
    func insertWordBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = [
            "title": title,
            "timestamp": Timestamp(date: Date())]
        wordBookRef.addDocument(data: data, completion: completionHandler)
    }
    
    func closeWordBook(of toClose: WordBook, completionHandler: @escaping CompletionWithoutData) {
        guard let id = toClose.id else {
            let error = AppError.generic(massage: "No wordBook ID")
            completionHandler(error)
            return
        }
        let field = ["_closed": true]
        wordBookRef.document(id).updateData(field, completion: completionHandler)
    }
    
}


// MARK: WordDatabase
extension FirestoreDB: WordDatabase {
    
    func fetchWords(_ wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>) {
        guard let id = wordBook.id else {
            let error = AppError.generic(massage: "No wordBook ID")
            completionHandler(nil, error)
            return
        }
        
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
    
    func insertWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                    "meaningText": wordInput.meaningText,
                                    "meaningImageURL": wordInput.meaningImageURL,
                                    "ganaText": wordInput.ganaText,
                                    "ganaImageURL": wordInput.ganaImageURL,
                                    "kanjiText": wordInput.kanjiText,
                                    "kanjiImageURL": wordInput.kanjiImageURL,
                                    "studyState": wordInput.studyState.rawValue]
        
        wordRef(of: wordInput.wordBookID).addDocument(data: data, completion: completionHandler)
    }
    
    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData) {
        guard let wordID = word.id else {
            print("Failed in Database updateStudyState")
            let error = AppError.generic(massage: "No ID in Word")
            completionHandler(error)
        }
        guard let wordBookID = word.wordBookID else {
            print("Failed in Database updateStudyState")
            let error = AppError.generic(massage: "No WordBookID in Word")
            completionHandler(error)
        }
        wordRef(of: wordBookID).document(wordID).updateData(["studyState" : newState.rawValue]) { error in
            completionHandler(error)
        }
    }
    
    func checkIfOverlap(word: Word, completionHandler: @escaping CompletionWithData<Bool>) {
        guard let wordBookID = word.wordBookID else {
            let error = AppError.generic(massage: "No wordBookID in checkIfOverlap")
            completionHandler(nil, error)
            return
        }
        wordRef(of: wordBookID).whereField("meaningText", isEqualTo: word.meaningText).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            completionHandler(documents.count != 0 ? true : false, nil)
        }
    }
    
    func copyWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: CompletionWithoutData) {
        guard let wordBookID = wordBook.id else {
            let error = AppError.generic(massage: "No wordBookID")
            completionHandler(error)
            return
        }
        
        group.enter()
        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                    "meaningText": word.meaningText,
                                    "meaningImageURL": word.meaningImageURL,
                                    "ganaText": word.ganaText,
                                    "ganaImageURL": word.ganaImageURL,
                                    "kanjiText": word.kanjiText,
                                    "kanjiImageURL": word.kanjiImageURL,
                                    "studyState": StudyState.undefined.rawValue]
        wordRef(of: wordBookID).addDocument(data: data) { error in
            if let error = error {
                completionHandler(error)
            }
            group.leave()
        }
        
    }
}

// MARK: SampleDatabase

extension FirestoreDB: SampleDatabase {
    func insertSample(_ wordInput: WordInput) {
        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                    "meaningText": wordInput.meaningText,
                                    "meaningImageURL": "",
                                    "ganaText": wordInput.ganaText,
                                    "ganaImageURL": "",
                                    "kanjiText": wordInput.kanjiText,
                                    "kanjiImageURL": "",
                                    "used": 0]
        sampleRef.addDocument(data: data)
    }
    
    
}

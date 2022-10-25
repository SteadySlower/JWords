//
//  Database.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

import Firebase
import FirebaseFirestore

protocol Database {
    // WordBook 관련
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>)
    func insertWordBook(title: String, completionHandler: @escaping CompletionWithoutData)
    func checkIfOverlap(wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>)
    func closeWordBook(of toClose: WordBook, completionHandler: @escaping CompletionWithoutData)
    
    // Word 관련
    func fetchWords(_ wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>)
    func insertWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData)
    func moveWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: @escaping CompletionWithoutData)
    
    // Sample 관련
    func insertSample(_ wordInput: WordInput)
    func fetchSample(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>)
    func updateUsed(of sample: Sample, to used: Int)
    
    // Today 관련
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodayBooks>)
    func updateTodayBooks(_ todayBooks: TodayBooks, _ completionHandler: @escaping CompletionWithoutData)
}

// Firebase에 직접 extension으로 만들어도 되지만 Firebase를 한단계 감싼 class를 만들었음.
final class FirestoreDB: Database {
    
    // Firestore singleton
        // lazy var를 사용한 이유는 FirebaseApp.configure()가 실행되고 나서 Firebase 객체를 init해야 하기 때문.
    private lazy var firestore: Firestore  = {
        Firestore.firestore()
    }()
    
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
    
    private lazy var todayRef = {
        firestore
        .collection("develop")
        .document("data")
        .collection("today")
    }()
}


// MARK: WordbookDatabase
extension FirestoreDB {
    
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        wordBookRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            
            guard let documents = snapshot?.documents else {
                let error = AppError.Firebase.noDocument
                completionHandler(nil, error)
                return
            }
            
            var wordBooks = [WordBook]()
            
            for document in documents {
                let id = document.documentID
                var dict = document.data()

                guard let timestamp = dict["timestamp"] as? Timestamp else {
                    let error = AppError.Firebase.noTimestamp
                    completionHandler(nil, error)
                    return
                }
                
                dict["createdAt"] = timestamp.dateValue()
                
                do {
                    wordBooks.append(try WordBookImpl(id: id, dict: dict))
                } catch let error {
                    completionHandler(nil, error)
                    return
                }
            }
            
            completionHandler(wordBooks, nil)
        }
    }
    
    func insertWordBook(title: String, completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = [
            "title": title,
            "timestamp": Timestamp(date: Date())]
        wordBookRef.addDocument(data: data, completion: completionHandler)
    }
    
    func checkIfOverlap(wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>) {
        wordRef(of: wordBook.id).whereField("meaningText", isEqualTo: meaningText).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let documents = snapshot?.documents else {
                let error = AppError.Firebase.noDocument
                completionHandler(nil, error)
                return
            }
            completionHandler(documents.count != 0 ? true : false, nil)
        }
    }
    
    func closeWordBook(of toClose: WordBook, completionHandler: @escaping CompletionWithoutData) {
        let field = ["_closed": true]
        wordBookRef.document(toClose.id).updateData(field, completion: completionHandler)
    }
    
}


// MARK: WordDatabase
extension FirestoreDB {

    func fetchWords(_ wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>) {
        wordRef(of: wordBook.id).order(by: "timestamp").getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            
            guard let documents = snapshot?.documents else {
                let error = AppError.Firebase.noDocument
                completionHandler(nil, error)
                return
            }
            
            var words = [Word]()
            
            for document in documents {
                let id = document.documentID
                var dict = document.data()
                
                guard let timestamp = document["timestamp"] as? Timestamp else {
                    let error = AppError.Firebase.noTimestamp
                    completionHandler(nil, error)
                    return
                }
                
                dict["createdAt"] = timestamp.dateValue()
                
                do {
                    words.append(try WordImpl(id: id, wordBookID: wordBook.id, dict: dict))
                } catch let error {
                    completionHandler(nil, error)
                    return
                }
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
        wordRef(of: word.wordBookID).document(word.id).updateData(["studyState" : newState.rawValue]) { error in
            completionHandler(error)
        }
    }
    
    func moveWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: @escaping CompletionWithoutData) {
        group.enter()
    
        wordRef(of: word.wordBookID).document(word.id).delete()
        
        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                    "meaningText": word.meaningText,
                                    "meaningImageURL": word.meaningImageURL,
                                    "ganaText": word.ganaText,
                                    "ganaImageURL": word.ganaImageURL,
                                    "kanjiText": word.kanjiText,
                                    "kanjiImageURL": word.kanjiImageURL,
                                    "studyState": StudyState.undefined.rawValue]
        wordRef(of: wordBook.id).addDocument(data: data) { error in
            if let error = error {
                completionHandler(error)
            }
            group.leave()
        }
        
    }
}

// MARK: SampleDatabase

extension FirestoreDB {
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
    
    func fetchSample(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>) {
        sampleRef
            .whereField("meaningText", isGreaterThanOrEqualTo: query)
            .whereField("meaningText", isLessThan: query + "힣")
            .getDocuments { snapshot, error in
                if let error = error {
                    completionHandler(nil, error)
                }
                
                guard let documents = snapshot?.documents else {
                    let error = AppError.Firebase.noDocument
                    completionHandler(nil, error)
                    return
                }
                
                var samples = [Sample]()
                
                for document in documents {
                    let id = document.documentID
                    var dict = document.data()
                    
                    guard let timestamp = dict["timestamp"] as? Timestamp else {
                        let error = AppError.Firebase.noTimestamp
                        completionHandler(nil, error)
                        return
                    }
                    
                    dict["createdAt"] = timestamp.dateValue()
                    
                    do {
                        samples.append(try SampleImpl(id: id, dict: dict))
                    } catch let error {
                        completionHandler(nil, error)
                        return
                    }
                }

                completionHandler(samples, nil)
            }
    }
    
    func updateUsed(of sample: Sample, to used: Int) {
        sampleRef.document(sample.id).updateData(["used" : used])
    }
}

//MARK: TodayDatebase

extension FirestoreDB {
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodayBooks>) {
        
    }
    
    func updateTodayBooks(_ todayBooks: TodayBooks, _ completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = [
            "studyIDs": todayBooks.studyIDs,
            "reviewIDs": todayBooks.reviewIDs,
            "timestamp": todayBooks.createdAt,
            "reviewedIDs": todayBooks.reviewIDs
        ]
        
        todayRef.addDocument(data: data) { error in
            if error != nil {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
}

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
    func insertWordBook(title: String, preferredFrontType: FrontType, completionHandler: @escaping CompletionWithoutData)
    func checkIfOverlap(wordBook: WordBook, meaningText: String, completionHandler: @escaping CompletionWithData<Bool>)
    func closeWordBook(of toClose: WordBook, completionHandler: @escaping CompletionWithoutData)
    
    // Word 관련
    func fetchWord(wordBookID: String, wordID: String, completionHandler: @escaping CompletionWithData<Word>)
    func fetchWords(_ wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>)
    func insertWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData)
    func moveWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: @escaping CompletionWithoutData)
    func updateWord(_ word: Word, _ wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
    
    // Sample 관련
    func insertSample(_ wordInput: WordInput)
    func fetchSample(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>)
    func fetchSampleByMeaning(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>)
    func updateUsed(of sample: Sample, to used: Int)
    
    // Today 관련
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodaySchedule>)
    func updateTodayBooks(_ todayBooks: TodaySchedule, _ completionHandler: @escaping CompletionWithoutData)
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
    
    private lazy var dataRef = {
        firestore
        .collection("develop")
        .document("data")
    }()
}


// MARK: WordbookDatabase
extension FirestoreDB {
    
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        
        
        wordBookRef
            .whereField("title", isGreaterThanOrEqualTo: "한자")
            .whereField("title", isLessThanOrEqualTo: "한자" + "\u{f8ff}")
            .getDocuments { snapshot, error in
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
                    wordBooks.append(try WordBook(id: id, dict: dict))
                } catch let error {
                    completionHandler(nil, error)
                    return
                }
            }
            
            completionHandler(wordBooks, nil)
        }
    }
    
    
//    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
//        wordBookRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
//            if let error = error {
//                completionHandler(nil, error)
//            }
//
//            guard let documents = snapshot?.documents else {
//                let error = AppError.Firebase.noDocument
//                completionHandler(nil, error)
//                return
//            }
//
//            var wordBooks = [WordBook]()
//
//            for document in documents {
//                let id = document.documentID
//                var dict = document.data()
//
//                guard let timestamp = dict["timestamp"] as? Timestamp else {
//                    let error = AppError.Firebase.noTimestamp
//                    completionHandler(nil, error)
//                    return
//                }
//
//                dict["createdAt"] = timestamp.dateValue()
//
//                do {
//                    wordBooks.append(try WordBook(id: id, dict: dict))
//                } catch let error {
//                    completionHandler(nil, error)
//                    return
//                }
//            }
//
//            completionHandler(wordBooks, nil)
//        }
//    }
//
    func insertWordBook(title: String, preferredFrontType: FrontType, completionHandler: @escaping CompletionWithoutData) {
        let data: [String : Any] = [
            "title": title,
            "preferredFrontType": preferredFrontType.rawValue,
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
    func fetchWord(wordBookID: String, wordID: String, completionHandler: @escaping CompletionWithData<Word>) {
        wordRef(of: wordBookID).document(wordID).getDocument { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            // TODO: handle error
            guard let id = snapshot?.documentID,
                  var dict = snapshot?.data(),
                  let timestamp = dict["timestamp"] as? Timestamp else { return }
            
            dict["createdAt"] = timestamp.dateValue()
            
            do {
                let word = try Word(id: id, wordBookID: wordBookID, dict: dict)
                completionHandler(word, nil)
                return
            } catch let error {
                completionHandler(nil, error)
                return
            }
        }
    }

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
                    words.append(try Word(id: id, wordBookID: wordBook.id, dict: dict))
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
    
    func updateWord(_ word: Word, _ wordInput: WordInput, completionHandler: @escaping CompletionWithoutData) {
        let data: [String: Any] = [
            "meaningText": wordInput.meaningText,
            "kanjiText": wordInput.kanjiText,
            "ganaText": wordInput.ganaText]
        wordRef(of: word.wordBookID).document(word.id).updateData(data) { error in
            completionHandler(error)
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
            .whereField("kanjiText", isEqualTo: query)
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
                        samples.append(try Sample(id: id, dict: dict))
                    } catch let error {
                        completionHandler(nil, error)
                        return
                    }
                }
                
                completionHandler(samples, nil)
            }
            
    }
    
    func fetchSampleByMeaning(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>) {
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
                        samples.append(try Sample(id: id, dict: dict))
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
    func getTodayBooks(_ completionHandler: @escaping CompletionWithData<TodaySchedule>) {
        dataRef.getDocument { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard var dict = snapshot?.data()?["today"] as? [String: Any] else {
                let emptyTodayBooks = TodaySchedule(studyIDs: [], reviewIDs: [], reviewedIDs: [], createdAt: Date())
                completionHandler(emptyTodayBooks, nil)
                return
            }
            
            guard let timestamp = dict["timestamp"] as? Timestamp else {
                let error = AppError.Firebase.noTimestamp
                completionHandler(nil, error)
                return
            }
            
            dict["createdAt"] = timestamp.dateValue()
            
            do {
                let todayBooks = try TodaySchedule(dict: dict)
                completionHandler(todayBooks, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
    }
    
    func updateTodayBooks(_ todayBooks: TodaySchedule, _ completionHandler: @escaping CompletionWithoutData) {
        
        let data: [String : Any] = [
            "studyIDs": todayBooks.studyIDs,
            "reviewIDs": todayBooks.reviewIDs,
            "timestamp": Timestamp(date: todayBooks.createdAt),
            "reviewedIDs": todayBooks.reviewedIDs
        ]
        
        dataRef.updateData(["today" : data]) { error in
            if error != nil {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
}

//
//  Database.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

import Firebase

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
    func copyWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: @escaping CompletionWithoutData)
    
    // Sample 관련
    func insertSample(_ wordInput: WordInput)
    func fetchSample(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>)
    func updateUsed(of sample: Sample, to used: Int)
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
}


// MARK: WordbookDatabase
extension FirestoreDB {
    
    func fetchWordBooks(completionHandler: @escaping CompletionWithData<[WordBook]>) {
        wordBookRef.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            let wordBooks = documents.compactMap({ try? $0.data(as: WordBookImpl.self) })
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
        guard let wordBookID = wordBook.id else {
            // TODO: handle Error
            let error = AppError.generic(massage: "No id in wordBook")
            completionHandler(nil, error)
            return
        }
        wordRef(of: wordBookID).whereField("meaningText", isEqualTo: meaningText).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            completionHandler(documents.count != 0 ? true : false, nil)
        }
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
extension FirestoreDB {

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
            return
        }
        guard let wordBookID = word.wordBookID else {
            print("Failed in Database updateStudyState")
            let error = AppError.generic(massage: "No WordBookID in Word")
            completionHandler(error)
            return
        }
        wordRef(of: wordBookID).document(wordID).updateData(["studyState" : newState.rawValue]) { error in
            completionHandler(error)
        }
    }
    
    func copyWord(_ word: Word, to wordBook: WordBook, group: DispatchGroup, completionHandler: @escaping CompletionWithoutData) {
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
                guard let documents = snapshot?.documents else { return }
                let samples = documents
                        .compactMap { try? $0.data(as: Sample.self) }
                        .sorted(by: { $0.used > $1.used })
                completionHandler(samples, nil)
            }
    }
    
    func updateUsed(of sample: Sample, to used: Int) {
        guard let id = sample.id else {
            print("No id in sample")
            return
        }
        sampleRef.document(id).updateData(["used" : used])
    }
}

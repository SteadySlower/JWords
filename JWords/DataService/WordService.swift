//
//  WordService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Firebase

typealias FireStoreCompletion = ((Error?) -> Void)?

class WordService {
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
    
    static func getWords(wordBookID id: String, completionHandler: @escaping ([Word]?, Error?) -> Void) {
        Constants.Collections.word(id).order(by: "timestamp").getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let documents = snapshot?.documents else { return }
            let words = documents.compactMap({ try? $0.data(as: Word.self) })
            completionHandler(words, nil)
        }
    }
    
    static func saveBook(title: String, completionHandler: FireStoreCompletion) {
        let data: [String : Any] = [
            "title": title,
            "timestamp": Timestamp(date: Date())]
        Constants.Collections.wordBooks.addDocument(data: data, completion: completionHandler)
    }
    
    static func saveWord(wordInput: WordInput, wordBookID: String, completionHandler: FireStoreCompletion) {
        let group = DispatchGroup()
        var meaningImageURL = ""
        var ganaImageURL = ""
        var kanjiImageURL = ""
        
        if let meaningImage = wordInput.meaningImage {
            ImageUploader.uploadImage(image: meaningImage, group: group) { url in
                meaningImageURL = url
            }
        }
        
        if let ganaImage = wordInput.ganaImage {
            ImageUploader.uploadImage(image: ganaImage, group: group) { url in
                ganaImageURL = url
            }
        }
        
        if let kanjiImage = wordInput.kanjiImage {
            ImageUploader.uploadImage(image: kanjiImage, group: group) { url in
                kanjiImageURL = url
            }
        }
        
        group.notify(queue: .global()) {
            let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                        "meaningText": wordInput.meaningText,
                                        "meaningImageURL": meaningImageURL,
                                        "ganaText": wordInput.ganaText,
                                        "ganaImageURL": ganaImageURL,
                                        "kanjiText": wordInput.kanjiText,
                                        "kanjiImageURL": kanjiImageURL,
                                        "studyState": wordInput.studyState.rawValue]
            Constants.Collections.word(wordBookID).addDocument(data: data, completion: completionHandler)
        }
    }
    
    static func updateStudyState(wordBookID: String, wordID: String, newState: StudyState,  completionHandler: @escaping (Error?) -> Void) {
        Constants.Collections.word(wordBookID).document(wordID).updateData(["studyState" : newState.rawValue]) { error in
            completionHandler(error)
        }
    }
    
    static func checkIfOverlap(wordBookID: String, meaningText: String, completionHandler: @escaping ((Bool?, Error?) -> Void)) {
        Constants.Collections.word(wordBookID).whereField("meaningText", isEqualTo: meaningText).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            completionHandler(documents.count != 0 ? true : false, nil)
        }
    }
    
    static func closeWordBook(of id: String, to to: String?, toMoveWords: [Word], completionHandler: FireStoreCompletion) {
        if let to = to {
            copyWords(toMoveWords, to: to) {
                closeBook(id, completionHandler: completionHandler)
            }
        } else {
            closeBook(id, completionHandler: completionHandler)
        }
        
    }
    
    static private func closeBook(_ id: String, completionHandler: FireStoreCompletion) {
        let field = ["_closed": true]
        Constants.Collections.wordBooks.document(id).updateData(field, completion: completionHandler)
    }
    
    static private func copyWords(_ words: [Word], to id: String, completionHandler: @escaping () -> Void) {
        let group = DispatchGroup()
        for word in words {
            copyWord(word, to: id, group: group)
        }
        group.notify(queue: .global()) {
            completionHandler()
        }
    }
    
    static private func copyWord(_ word: Word, to id: String, group: DispatchGroup) {
        group.enter()
        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                    "meaningText": word.meaningText,
                                    "meaningImageURL": word.meaningImageURL,
                                    "ganaText": word.ganaText,
                                    "ganaImageURL": word.ganaImageURL,
                                    "kanjiText": word.kanjiText,
                                    "kanjiImageURL": word.kanjiImageURL,
                                    "studyState": StudyState.undefined.rawValue]
        Constants.Collections.word(id).addDocument(data: data) { error in
            //TODO: handle error
            if let error = error { print(error) }
            group.leave()
        }
    }

}

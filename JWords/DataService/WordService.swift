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
        Constants.Collections.wordBooks.getDocuments { snapshot, error in
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
        var frontImageURL = ""
        var backImageURL = ""
        
        if let frontImage = wordInput.frontImage {
            ImageUploader.uploadImage(image: frontImage, group: group) { url in
                frontImageURL = url
            }
        }
        
        if let backImage = wordInput.backImage {
            ImageUploader.uploadImage(image: backImage, group: group) { url in
                backImageURL = url
            }
        }
        
        group.notify(queue: .global()) {
            let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
                                        "frontText": wordInput.frontText,
                                        "frontImageURL": frontImageURL,
                                        "backText": wordInput.backText,
                                        "backImageURL": backImageURL,
                                        "studyState": wordInput.studyState.rawValue]
            Constants.Collections.word(wordBookID).addDocument(data: data, completion: completionHandler)
        }
    }
    
    static func updateStudyState(wordBookID: String, wordID: String, newState: StudyState,  completionHandler: @escaping (Error?) -> Void) {
        Constants.Collections.word(wordBookID).document(wordID).updateData(["studyState" : newState.rawValue]) { error in
            completionHandler(error)
        }
    }
    
    static func checkIfOverlap(wordBookID: String, frontText: String, completionHandler: @escaping ((Bool?, Error?) -> Void)) {
        Constants.Collections.word(wordBookID).whereField("frontText", isEqualTo: frontText).getDocuments { snapshot, error in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            completionHandler(documents.count != 0 ? true : false, nil)
        }
    }
}

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
}

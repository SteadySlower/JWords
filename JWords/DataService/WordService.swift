//
//  WordService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Foundation

typealias CompletionWithoutData = ((Error?) -> Void)
typealias CompletionWithData<T> = ((T?, Error?) -> Void)

protocol WordService {
    func getWords(wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>)
    func saveWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData)
    func moveWords(_ words: [Word], to wordBook: WordBook, completionHandler: @escaping CompletionWithoutData)
    func updateWord(_ word: Word, _ wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
}

final class WordServiceImpl: WordService {
    
    // DB
    let db: Database
    let iu: ImageUploader
    
    // Initializer
    init(database: Database, imageUploader: ImageUploader) {
        self.db = database
        self.iu = imageUploader
    }
    
    // functions
    
    func getWords(wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>) {
        db.fetchWords(wordBook, completionHandler: completionHandler)
    }
    
    func saveWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData) {
        let group = DispatchGroup()
        
        var wordInput = wordInput
        
        // 동시성 이슈를 해결하기 위해서 따로 변수를 사용하고 나중에 완료되면 wordInput에 접근하는 것으로
        var meaningImageURL = ""
        var ganaImageURL = ""
        var kanjiImageURL = ""
        var imageUploadError: Error?
        
        if let meaningImage = wordInput.meaningImage {
            iu.uploadImage(image: meaningImage, group: group) { url, error in
                if let error = error {
                    imageUploadError = error
                    return
                }
                guard let url = url else {
                    print("URL from image uploader is nil")
                    imageUploadError = AppError.WordService.noWordImageURL
                    return
                }

                meaningImageURL = url
            }
        }
        
        if let ganaImage = wordInput.ganaImage {
            iu.uploadImage(image: ganaImage, group: group) { url, error in
                if let error = error {
                    completionHandler(error)
                    return
                }
                guard let url = url else {
                    imageUploadError = AppError.WordService.noWordImageURL
                    return
                }
                
                ganaImageURL = url
            }
        }
        
        if let kanjiImage = wordInput.kanjiImage {
            iu.uploadImage(image: kanjiImage, group: group) { url, error in
                if let error = error {
                    completionHandler(error)
                    return
                }
                guard let url = url else {
                    imageUploadError = AppError.WordService.noWordImageURL
                    return
                }
                
                kanjiImageURL = url
            }
        }
        
        group.notify(queue: .global()) { [weak self] in
            if let imageUploadError = imageUploadError {
                completionHandler(imageUploadError)
                return
            }
            
            wordInput.meaningImageURL = meaningImageURL
            wordInput.ganaImageURL = ganaImageURL
            wordInput.kanjiImageURL = kanjiImageURL
            
            self?.db.insertWord(wordInput: wordInput, completionHandler: completionHandler)
        }
    }
    
    func updateStudyState(word: Word, newState: StudyState,  completionHandler: @escaping CompletionWithoutData) {
        db.updateStudyState(word: word, newState: newState, completionHandler: completionHandler)
    }
    
    func moveWords(_ words: [Word], to wordBook: WordBook, completionHandler: @escaping CompletionWithoutData) {
        let group = DispatchGroup()
        
        var copyWordError: Error? = nil
        
        // word를 옮기는 과정에서 에러가 나면 copyWordError에 할당
        for word in words {
            db.moveWord(word, to: wordBook, group: group) { error in
                copyWordError = error
            }
        }
        group.notify(queue: .global()) {
            completionHandler(copyWordError)
        }
    }
    
    func updateWord(_ word: Word, _ wordInput: WordInput, completionHandler: @escaping CompletionWithoutData) {
        db.updateWord(word, wordInput, completionHandler: completionHandler)
    }
}

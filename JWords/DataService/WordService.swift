//
//  WordService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Firebase

typealias CompletionWithoutData = ((Error?) -> Void)
typealias CompletionWithData<T> = ((T?, Error?) -> Void)

protocol WordService {
    func getWords(wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>)
    func saveWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData)
    // TODO: 나중에 word 객체에 wordBookID 넣어서 wordBookID argument 삭제
    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData)
    func copyWords(_ words: [Word], to wordBook: WordBook, completionHandler: @escaping CompletionWithoutData)
}

final class WordServiceImpl: WordService {
    
    // DB
    let db: WordDatabase
    let iu: ImageUploader
    
    // Initializer
    init(database: WordDatabase, imageUploader: ImageUploader) {
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
        
        if let meaningImage = wordInput.meaningImage {
            iu.uploadImage(image: meaningImage, group: group) { url in
                meaningImageURL = url
            }
        }
        
        if let ganaImage = wordInput.ganaImage {
            iu.uploadImage(image: ganaImage, group: group) { url in
                ganaImageURL = url
            }
        }
        
        if let kanjiImage = wordInput.kanjiImage {
            iu.uploadImage(image: kanjiImage, group: group) { url in
                kanjiImageURL = url
            }
        }
        
        group.notify(queue: .global()) { [weak self] in
            wordInput.meaningImageURL = meaningImageURL
            wordInput.ganaImageURL = ganaImageURL
            wordInput.kanjiImageURL = kanjiImageURL
            
            self?.db.insertWord(wordInput: wordInput, completionHandler: completionHandler)
        }
    }
    
    func updateStudyState(word: Word, newState: StudyState,  completionHandler: @escaping CompletionWithoutData) {
        db.updateStudyState(word: word, newState: newState, completionHandler: completionHandler)
    }
    
    func copyWords(_ words: [Word], to wordBook: WordBook, completionHandler: @escaping CompletionWithoutData) {
        let group = DispatchGroup()
        
        var copyWordError: Error? = nil
        
        // word를 옮기는 과정에서 에러가 나면 copyWordError에 할당
        for word in words {
            db.copyWord(word, to: wordBook, group: group) { error in
                copyWordError = error
            }
        }
        group.notify(queue: .global()) {
            completionHandler(copyWordError)
        }
    }
    
    // Examples를 검색하는 함수
    static func fetchExamples(_ query: String, completionHandler: @escaping ([Sample]?, Error?) -> Void) {
        Constants.Collections.examples
            .whereField("meaningText", isGreaterThanOrEqualTo: query)
            .whereField("meaningText", isLessThan: query + "힣")
            .getDocuments { snapshot, error in
                if let error = error {
                    completionHandler(nil, error)
                }
                guard let documents = snapshot?.documents else { return }
                let examples = documents
                        .compactMap { try? $0.data(as: Sample.self) }
                        .sorted(by: { $0.used > $1.used })
                completionHandler(examples, nil)
            }
    }
    
    // Examples 사용되서 used에 + 1하는 함수
    static func updateUsed(of example: Sample) {
        guard let id = example.id else {
            print("No id of example in updateUsed")
            return
        }
        Constants.Collections.examples.document(id).updateData(["used" : example.used + 1])
    }

}

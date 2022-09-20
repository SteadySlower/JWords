//
//  MockWordService.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/14.
//

@testable import JWords

class MockWordService {
    var getWordsSuccess: [Word]?
    var getWordsError: Error?
    var saveWordError: Error?
    var updateStudyStateError: Error?
    var copyWordsError: Error?
}

extension MockWordService: WordService {
    func getWords(wordBook: WordBook, completionHandler: @escaping CompletionWithData<[Word]>) {
        if let getWordsError = getWordsError {
            completionHandler(nil, getWordsError)
            return
        }
        completionHandler(getWordsSuccess, nil)
    }

    func saveWord(wordInput: WordInput, completionHandler: @escaping CompletionWithoutData) {
        if let saveWordError = saveWordError {
            completionHandler(saveWordError)
            return
        }
        completionHandler(nil)
    }

    func updateStudyState(word: Word, newState: StudyState, completionHandler: @escaping CompletionWithoutData) {
        if let updateStudyStateError = updateStudyStateError {
            completionHandler(updateStudyStateError)
            return
        }
        completionHandler(nil)
    }

    func moveWords(_ words: [Word], to wordBook: WordBook, completionHandler: @escaping CompletionWithoutData) {
        if let copyWordsError = copyWordsError {
            completionHandler(copyWordsError)
            return
        }
        completionHandler(nil)
    }


}

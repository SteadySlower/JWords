//
//  StudyViewModelTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/30.
//

import Quick
import Nimble
@testable import JWords

class StudyViewModelTest: QuickSpec {
    
    override func spec() {
        var viewModel: StudyView.ViewModel!
        var wordService: MockWordService!
        
        func prepare(wordBook: WordBook) {
            wordService = MockWordService()
            viewModel = StudyView.ViewModel(wordBook: wordBook, wordService: wordService)
        }
        
        func prepare(words: [Word]) {
            wordService = MockWordService()
            viewModel = StudyView.ViewModel(words: words, wordService: wordService)
        }
        
        describe("wordBook") {
            
        }
    }
}

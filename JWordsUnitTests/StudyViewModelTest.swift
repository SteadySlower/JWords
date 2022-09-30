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
        
        func prepare(wordBook: WordBook = MockWordBook()) {
            wordService = MockWordService()
            viewModel = StudyView.ViewModel(wordBook: wordBook, wordService: wordService)
        }
        
        func prepare(words: [Word]) {
            wordService = MockWordService()
            viewModel = StudyView.ViewModel(words: words, wordService: wordService)
        }
        
        describe("wordBook") {
            context("when viewModel is initialized with a wordBook") {
                beforeEach {
                    prepare()
                }
                it("should be not nil") {
                    expect(viewModel.wordBook).notTo(beNil())
                }
            }
            context("when viewModel is initialized with words") {
                beforeEach {
                    var words = [Word]()
                    for _ in 0..<Random.int(from: 1, to: 100) {
                        words.append(MockWord())
                    }
                    prepare(words: words)
                }
                it("should be nil") {
                    expect(viewModel.wordBook).to(beNil())
                }
            }
        }
    }
}

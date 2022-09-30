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
        
        func randomWords(_ count: Int) -> [Word] {
            var words = [Word]()
            for _ in 0..<count {
                words.append(MockWord())
            }
            return words
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
                    prepare(words: randomWords(Random.int(from: 1, to: 100)))
                }
                it("should be nil") {
                    expect(viewModel.wordBook).to(beNil())
                }
            }
        }
        
        describe("words") {
            context("when viewModel is initialized with a wordBook") {
                beforeEach {
                    prepare()
                }
                context("when words are fetched successfully") {
                    let count = Random.int(from: 1, to: 100)
                    beforeEach {
                        wordService.getWordsSuccess = randomWords(count)
                        viewModel.fetchWords()
                    }
                    it("should have the same count with getWordsSuccess") {
                        expect(viewModel.words.count).to(equal(count))
                    }
                }
                context("when words fails to be fetched") {
                    beforeEach {
                        viewModel.fetchWords()
                    }
                    it("should be empty") {
                        expect(viewModel.words).to(beEmpty())
                    }
                }
            }
            context("when viewModel is initialized with words") {
                let count = Random.int(from: 1, to: 100)
                beforeEach {
                    let words = randomWords(count)
                    prepare(words: words)
                }
                it("should have the same count with the words") {
                    expect(viewModel.words.count).to(equal(count))
                }
            }
        }
    }
}

//
//  WordBookCloseViewModelTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2022/10/09.
//

import Quick
import Nimble
@testable import JWords

class WordBookCloseViewModelTest: QuickSpec {
    
    override func spec() {
        var viewModel: WordBookCloseView.ViewModel!
        var dependency: MockDependency!
        
        func prepare(toClose: WordBook, toMoveWords: [Word]) {
            let wordBookService = MockWordBookService()
            let wordService = MockWordService()
            let sampleService = MockSampleService()
            let todayService = MockTodayService()
            dependency = MockDependency(wordBookService: wordBookService, wordService: wordService, sampleService: sampleService, todayService: todayService)
            viewModel = WordBookCloseView.ViewModel(toClose: toClose, toMoveWords: toMoveWords, dependency: dependency)
        }
        
        describe("toMoveWords") {
            context("when viewModel is initialized with array of words") {
                it("'s count should be equal to the count of the array") {
                    var wordArray = [Word]()
                    let arrayCount = Random.int(from: 2, to: 100)
                    for _ in 0..<arrayCount {
                        wordArray.append(MockWord())
                    }
                    prepare(toClose: MockWordBook(), toMoveWords: wordArray)
                    expect(viewModel.toMoveWords.count).to(equal(arrayCount))
                }
            }
        }
    }
    
}

//
//  HomeViewModelTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2022/10/04.
//

import Quick
import Nimble
@testable import JWords

class HomeViewModelTest: QuickSpec {
    
    override func spec() {
        var viewModel: HomeView.ViewModel!
        var wordBookService: MockWordBookService!
        
        func prepare() {
            wordBookService = MockWordBookService()
            viewModel = HomeView.ViewModel(wordBookService: wordBookService)
        }
        
        describe("wordBooks") {
            beforeEach {
                prepare()
            }
            context("when wordBooks are got successfully") {
                beforeEach {
                    var books = [WordBook]()
                    for _ in 1..<Random.int(from: 2, to: 100) {
                        books.append(MockWordBook())
                    }
                    wordBookService.getWordBooksSuccess = books
                    viewModel.fetchWordBooks()
                }
                it("should be not empty") {
                    expect(viewModel.wordBooks).notTo(beEmpty())
                }
            }
            context("when wordbooks fails to be got") {
                beforeEach {
                    viewModel.fetchWordBooks()
                }
                it("should be empty") {
                    expect(viewModel.wordBooks).to(beEmpty())
                }
            }
        }
        
    }
    
}

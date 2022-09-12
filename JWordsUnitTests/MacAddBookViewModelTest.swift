//
//  MacAddBookViewModelTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2022/09/10.
//

import Quick
import Nimble
@testable import JWords

class MacAddBookViewModelTest: QuickSpec {
    
    override func spec() {
        var viewModel: MacAddBookView.ViewModel!
        var wordBookService: MockWordBookService!
        
        func prepare() {
            wordBookService = MockWordBookService()
            viewModel = MacAddBookView.ViewModel(wordBookService: wordBookService)
        }
        
        describe("bookName") {
            beforeEach {
                prepare()
                viewModel.bookName = Random.string
            }
            context("when saveBook succeeded") {
                it("should be emtpy") {
                    viewModel.saveBook()
                    expect(viewModel.bookName.isEmpty).to(beTrue())
                }
            }
            context("when saveBook failed") {
                it("should be not be empty") {
                    wordBookService.saveBookError = AppError.generic(massage: "Mock Error")
                    viewModel.saveBook()
                    expect(viewModel.bookName.isEmpty).to(beFalse())
                }
            }
        }
        
        describe("isSaveButtonUnable") {
            beforeEach {
                prepare()
            }
            context("when bookName is empty") {
                it("should be false") {
                    viewModel.bookName = Random.string
                    expect(viewModel.isSaveButtonUnable).to(beFalse())
                }
            }
            context("when bookName is not empty") {
                it("shoule be true") {
                    viewModel.bookName = "bookName"
                }
            }
        }
        
    }
    
}


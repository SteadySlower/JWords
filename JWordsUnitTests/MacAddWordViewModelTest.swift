//
//  MacAddWordViewModelTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/14.
//

import Quick
import Nimble
@testable import JWords

class MacAddWordViewModelTest: QuickSpec {
    
    override func spec() {
        var viewModel: MacAddWordView.ViewModel!
        var dependency: MockDependency!
        var wordBookService: MockWordBookService!
        var wordService: MockWordService!
        var sampleService: MockSampleService!
        var todayService: MockTodayService!
        
        func prepare() {
            wordBookService = MockWordBookService()
            wordService = MockWordService()
            sampleService = MockSampleService()
            todayService = MockTodayService()
            dependency = MockDependency(wordBookService: wordBookService, wordService: wordService, sampleService: sampleService, todayService: todayService)
            viewModel = MacAddWordView.ViewModel(dependency)
        }
        
        describe("meaningText") {
            beforeEach {
                prepare()
            }
            context("when wordBooks are got successfully") {
                beforeEach {
                    var books = [WordBook]()
                    for _ in 0..<Random.int(from: 1, to: 100) {
                        books.append(MockWordBook())
                    }
                    wordBookService.getWordBooksSuccess = books
                    viewModel.getWordBooks()
                }
                context("when a book is selected") {
                    beforeEach {
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    }
                    context("when a word is saved with a meaningText") {
                        beforeEach {
                            viewModel.meaningText = Random.string
                            viewModel.saveWord()
                        }
                        it("should be empty") {
                            expect(viewModel.meaningText).to(beEmpty())
                        }
                    }
                }
                context("when a book is not selected") {
                    context("when a word is saved with a meaningText") {
                        beforeEach {
                            viewModel.meaningText = Random.string
                            viewModel.saveWord()
                        }
                        it("should not be empty") {
                            expect(viewModel.meaningText).notTo(beEmpty())
                        }
                    }
                }
            }
            context("when wordBooks fail to be get") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with a meaningText") {
                    beforeEach {
                        viewModel.meaningText = Random.string
                        viewModel.saveWord()
                    }
                    it("should not be empty") {
                        expect(viewModel.meaningText).notTo(beEmpty())
                    }
                }
            }
        }
        
        describe("meaningImage") {
            beforeEach {
                prepare()
            }
        }
        
        describe("ganaText") {
            
        }
        
        describe("ganaImage") {
            
        }
        
        describe("kanjiText") {
            
        }
        
        describe("kanjiImage") {
            
        }
        
        describe("bookList") {
            
        }
        
        describe("selectedBookIndex") {
            
        }
        
        describe("didBooksFetched") {
            
        }
        
        describe("isUploading") {
            
        }
        
        describe("selectedBook") {
            
        }
        
        describe("samples") {
            
        }
        
        describe("selectedSampleID") {
            
        }
        
        describe("selectedSample") {
            
        }
        
        describe("didExampleUsed") {
            
        }
        
        describe("isSaveButtonUnable") {
            
        }
        
        describe("isCheckingOverlap") {
            
        }
        
        describe("isOverlapped") {
            
        }
        
        describe("overlapCheckButtonTitle") {
            
        }
    }
    
}

//
//  MacAddWordViewModelTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/14.
//

import Quick
import Nimble
@testable import JWords
import UIKit

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
        
        func getWordBooksSuccessfully() {
            var books = [WordBook]()
            for _ in 1..<Random.int(from: 2, to: 100) {
                books.append(MockWordBook())
            }
            wordBookService.getWordBooksSuccess = books
            viewModel.getWordBooks()
        }
        
        describe("meaningText") {
            beforeEach {
                prepare()
            }
            // saveBooks하면 nil 되는지 테스트
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
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
            // insert와 clear 함수 테스트
            context("when an image inserted with inputType of .meaning") {
                beforeEach {
                    let image = UIImage()
                    viewModel.insertImage(of: .meaning, image: image)
                }
                it("should be not nil") {
                    expect(viewModel.meaningImage).notTo(beNil())
                }
                context("when the image with inputType of .meaning is cleared") {
                    beforeEach {
                        viewModel.clearImageInput(.meaning)
                    }
                    it("should be nil") {
                        expect(viewModel.meaningImage).to(beNil())
                    }
                }
            }
            
            // saveWord 일 때 nil 되는지 테스트
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                context("when a book is selected") {
                    beforeEach {
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    }
                    context("when a word is saved with an inserted meaning image") {
                        beforeEach {
                            let image = UIImage()
                            viewModel.insertImage(of: .meaning, image: image)
                            viewModel.saveWord()
                        }
                        it("should be nil") {
                            expect(viewModel.meaningImage).to(beNil())
                        }
                    }
                }
                context("when a book is not selected") {
                    context("when a word is saved with an inserted meaning image") {
                        beforeEach {
                            let image = UIImage()
                            viewModel.insertImage(of: .meaning, image: image)
                            viewModel.saveWord()
                        }
                        it("should not be nil") {
                            expect(viewModel.meaningImage).notTo(beNil())
                        }
                    }
                }
            }
            
            context("when wordBooks fail to be get") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with an inserted meaning image") {
                    beforeEach {
                        let image = UIImage()
                        viewModel.insertImage(of: .meaning, image: image)
                        viewModel.saveWord()
                    }
                    it("should not be nil") {
                        expect(viewModel.meaningImage).notTo(beNil())
                    }
                }
            }
        }
        
        describe("ganaText") {
            beforeEach {
                prepare()
            }
            // saveBooks하면 nil 되는지 테스트
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                context("when a book is selected") {
                    beforeEach {
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    }
                    context("when a word is saved with a meaningText") {
                        beforeEach {
                            viewModel.ganaText = Random.string
                            viewModel.saveWord()
                        }
                        it("should be empty") {
                            expect(viewModel.ganaText).to(beEmpty())
                        }
                    }
                }
                context("when a book is not selected") {
                    context("when a word is saved with a meaningText") {
                        beforeEach {
                            viewModel.ganaText = Random.string
                            viewModel.saveWord()
                        }
                        it("should not be empty") {
                            expect(viewModel.ganaText).notTo(beEmpty())
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
                        viewModel.ganaText = Random.string
                        viewModel.saveWord()
                    }
                    it("should not be empty") {
                        expect(viewModel.ganaText).notTo(beEmpty())
                    }
                }
            }
        }
        
        describe("ganaImage") {
            beforeEach {
                prepare()
            }
            // insert와 clear 함수 테스트
            context("when an image inserted with inputType of .gana") {
                beforeEach {
                    let image = UIImage()
                    viewModel.insertImage(of: .gana, image: image)
                }
                it("should be not nil") {
                    expect(viewModel.ganaImage).notTo(beNil())
                }
                context("when the image with inputType of .gana is cleared") {
                    beforeEach {
                        viewModel.clearImageInput(.gana)
                    }
                    it("should be nil") {
                        expect(viewModel.ganaImage).to(beNil())
                    }
                }
            }
            
            // saveWord 일 때 nil 되는지 테스트
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                context("when a book is selected") {
                    beforeEach {
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    }
                    context("when a word is saved with an inserted gana image") {
                        beforeEach {
                            let image = UIImage()
                            viewModel.insertImage(of: .gana, image: image)
                            viewModel.saveWord()
                        }
                        it("should be nil") {
                            expect(viewModel.ganaImage).to(beNil())
                        }
                    }
                }
                context("when a book is not selected") {
                    context("when a word is saved with an inserted gana image") {
                        beforeEach {
                            let image = UIImage()
                            viewModel.insertImage(of: .gana, image: image)
                            viewModel.saveWord()
                        }
                        it("should not be nil") {
                            expect(viewModel.ganaImage).notTo(beNil())
                        }
                    }
                }
            }
            
            context("when wordBooks fail to be get") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with an inserted gana image") {
                    beforeEach {
                        let image = UIImage()
                        viewModel.insertImage(of: .gana, image: image)
                        viewModel.saveWord()
                    }
                    it("should not be nil") {
                        expect(viewModel.ganaImage).notTo(beNil())
                    }
                }
            }
        }
        
        describe("kanjiText") {
            beforeEach {
                prepare()
            }
            // saveBooks하면 nil 되는지 테스트
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                context("when a book is selected") {
                    beforeEach {
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    }
                    context("when a word is saved with a meaningText") {
                        beforeEach {
                            viewModel.kanjiText = Random.string
                            viewModel.saveWord()
                        }
                        it("should be empty") {
                            expect(viewModel.kanjiText).to(beEmpty())
                        }
                    }
                }
                context("when a book is not selected") {
                    context("when a word is saved with a meaningText") {
                        beforeEach {
                            viewModel.kanjiText = Random.string
                            viewModel.saveWord()
                        }
                        it("should not be empty") {
                            expect(viewModel.kanjiText).notTo(beEmpty())
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
                        viewModel.kanjiText = Random.string
                        viewModel.saveWord()
                    }
                    it("should not be empty") {
                        expect(viewModel.kanjiText).notTo(beEmpty())
                    }
                }
            }
        }
        
        describe("kanjiImage") {
            beforeEach {
                prepare()
            }
            // insert와 clear 함수 테스트
            context("when an image inserted with inputType of .kanji") {
                beforeEach {
                    let image = UIImage()
                    viewModel.insertImage(of: .kanji, image: image)
                }
                it("should be not nil") {
                    expect(viewModel.kanjiImage).notTo(beNil())
                }
                context("when the image with inputType of .kanji is cleared") {
                    beforeEach {
                        viewModel.clearImageInput(.kanji)
                    }
                    it("should be nil") {
                        expect(viewModel.kanjiImage).to(beNil())
                    }
                }
            }
            
            // saveWord 일 때 nil 되는지 테스트
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                context("when a book is selected") {
                    beforeEach {
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    }
                    context("when a word is saved with an inserted kanji image") {
                        beforeEach {
                            let image = UIImage()
                            viewModel.insertImage(of: .kanji, image: image)
                            viewModel.saveWord()
                        }
                        it("should be nil") {
                            expect(viewModel.kanjiImage).to(beNil())
                        }
                    }
                }
                context("when a book is not selected") {
                    context("when a word is saved with an inserted kanji image") {
                        beforeEach {
                            let image = UIImage()
                            viewModel.insertImage(of: .kanji, image: image)
                            viewModel.saveWord()
                        }
                        it("should not be nil") {
                            expect(viewModel.kanjiImage).notTo(beNil())
                        }
                    }
                }
            }
            
            context("when wordBooks fail to be get") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with an inserted gana image") {
                    beforeEach {
                        let image = UIImage()
                        viewModel.insertImage(of: .gana, image: image)
                        viewModel.saveWord()
                    }
                    it("should not be nil") {
                        expect(viewModel.ganaImage).notTo(beNil())
                    }
                }
            }
        }
        
        describe("bookList") {
            beforeEach {
                prepare()
            }
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                it("should be not empty") {
                    expect(viewModel.bookList).notTo(beEmpty())
                }
            }
            context("when wordBooks fail to be get") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                it("should be empty") {
                    expect(viewModel.bookList).to(beEmpty())
                }
            }
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

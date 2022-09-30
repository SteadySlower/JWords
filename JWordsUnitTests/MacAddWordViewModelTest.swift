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
        
        func getSamplesSuccessfully() {
            var samples = [Sample]()
            for _ in 1..<Random.int(from: 2, to: 100) {
                samples.append(MockSample())
            }
            sampleService.getSamplesSuccess = samples
            viewModel.getExamples()
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
            context("when wordBooks fail to be got") {
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
                    let image = InputImageType()
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
                            let image = InputImageType()
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
                            let image = InputImageType()
                            viewModel.insertImage(of: .meaning, image: image)
                            viewModel.saveWord()
                        }
                        it("should not be nil") {
                            expect(viewModel.meaningImage).notTo(beNil())
                        }
                    }
                }
            }
            
            context("when wordBooks fail to be got") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with an inserted meaning image") {
                    beforeEach {
                        let image = InputImageType()
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
            context("when wordBooks fail to be got") {
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
            // trimPastedText에 대한 test
            context("when a pasted text from dictionary is trimmed") {
                let ganaString = Random.string
                let kanjiString = Random.string
                beforeEach {
                    let dictionaryString = "\(ganaString) [\(kanjiString)]"
                    viewModel.trimPastedText(dictionaryString)
                }
                it("should be equal to ganaString from dictionary") {
                    expect(viewModel.ganaText).to(equal(ganaString))
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
                    let image = InputImageType()
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
                            let image = InputImageType()
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
                            let image = InputImageType()
                            viewModel.insertImage(of: .gana, image: image)
                            viewModel.saveWord()
                        }
                        it("should not be nil") {
                            expect(viewModel.ganaImage).notTo(beNil())
                        }
                    }
                }
            }
            
            context("when wordBooks fail to be got") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with an inserted gana image") {
                    beforeEach {
                        let image = InputImageType()
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
            context("when wordBooks fail to be got") {
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
            // trimPastedText에 대한 test
            context("when a pasted text from dictionary is trimmed") {
                let ganaString = Random.string
                let kanjiString = Random.string
                beforeEach {
                    let dictionaryString = "\(ganaString) [\(kanjiString)]"
                    viewModel.trimPastedText(dictionaryString)
                }
                it("should be equal to kanjiString from dictionary") {
                    expect(viewModel.kanjiText).to(equal(kanjiString))
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
                    let image = InputImageType()
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
                            let image = InputImageType()
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
                            let image = InputImageType()
                            viewModel.insertImage(of: .kanji, image: image)
                            viewModel.saveWord()
                        }
                        it("should not be nil") {
                            expect(viewModel.kanjiImage).notTo(beNil())
                        }
                    }
                }
            }
            
            context("when wordBooks fail to be got") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                context("when a word is saved with an inserted gana image") {
                    beforeEach {
                        let image = InputImageType()
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
            context("when wordBooks fail to be got") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                it("should be empty") {
                    expect(viewModel.bookList).to(beEmpty())
                }
            }
        }
        
        
        describe("didBooksFetched") {
            beforeEach {
                prepare()
            }
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                it("should be true") {
                    expect(viewModel.didBooksFetched).to(beTrue())
                }
            }
            context("when wordBooks fail to be got") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                it("should be true") {
                    expect(viewModel.didBooksFetched).to(beTrue())
                }
            }
        }
        
        describe("wordBookPickerDefaultText") {
            beforeEach {
                prepare()
            }
            context("when wordBooks are got successfully") {
                beforeEach {
                    getWordBooksSuccessfully()
                }
                it("should be '단어장을 선택해주세요'") {
                    expect(viewModel.wordBookPickerDefaultText).to(equal("단어장을 선택해주세요"))
                }
            }
            context("when wordBooks fail to be got") {
                beforeEach {
                    viewModel.getWordBooks()
                }
                it("should be '단어장 리스트 불러오기 실패'") {
                    expect(viewModel.wordBookPickerDefaultText).to(equal("단어장 리스트 불러오기 실패"))
                }
            }
            context("when wordBooks are not yet got") {
                it("should be '단어장 불러오는 중...'") {
                    expect(viewModel.wordBookPickerDefaultText).to(equal("단어장 불러오는 중..."))
                }
            }
        }
        
        describe("samples") {
            beforeEach {
                prepare()
            }
            context("when samples are got successfully") {
                beforeEach {
                    getSamplesSuccessfully()
                }
                it("should not be empty") {
                    expect(viewModel.samples).notTo(beEmpty())
                }
                context("when word is saved successfully") {
                    beforeEach {
                        getWordBooksSuccessfully()
                        viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                        viewModel.saveWord()
                    }
                    it("should be empty") {
                        expect(viewModel.samples).to(beEmpty())
                    }
                }
            }
            context("when samples fail to be got") {
                beforeEach {
                    viewModel.getExamples()
                }
                it("should be empty") {
                    expect(viewModel.samples).to(beEmpty())
                }
            }
        }
        
        describe("isSaveButtonUnable") {
            beforeEach {
                prepare()
            }
            context("when meaningText is not empty or meaningImage is not nil") {
                beforeEach {
                    if Random.bool {
                        viewModel.meaningText = Random.string
                    }
                    if Random.bool {
                        viewModel.insertImage(of: .meaning, image: InputImageType())
                    }
                    if viewModel.meaningText.isEmpty && viewModel.meaningImage == nil {
                        viewModel.meaningText = Random.string
                    }
                }
                context("when ganaText is not empty or ganaImage is not nil") {
                    beforeEach {
                        if Random.bool {
                            viewModel.ganaText = Random.string
                        }
                        if Random.bool {
                            viewModel.insertImage(of: .gana, image: InputImageType())
                        }
                        if viewModel.ganaText.isEmpty && viewModel.ganaImage == nil {
                            viewModel.ganaText = Random.string
                        }
                    }
                    it("should be false") {
                        expect(viewModel.isSaveButtonUnable).to(beFalse())
                    }
                }
                context("when kanjiText is not empty or kanjiImage is not nil") {
                    beforeEach {
                        if Random.bool {
                            viewModel.kanjiText = Random.string
                        }
                        if Random.bool {
                            viewModel.insertImage(of: .kanji, image: InputImageType())
                        }
                        if viewModel.kanjiText.isEmpty && viewModel.kanjiImage == nil {
                            viewModel.kanjiText = Random.string
                        }
                    }
                    it("should be false") {
                        expect(viewModel.isSaveButtonUnable).to(beFalse())
                    }
                }
            }
            context("when meaningText is empty and meaningImage is nil") {
                it("should be true") {
                    expect(viewModel.isSaveButtonUnable).to(beTrue())
                }
            }
        }
        
        describe("isOverlapped") {
            beforeEach {
                prepare()

            }
            context("when wordBooks are got successfully and a book is selected") {
                beforeEach {
                    getWordBooksSuccessfully()
                    viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                }
                it("should be nil at first") {
                    expect(viewModel.isOverlapped).to(beNil())
                }
                context("when checkIfOverlap is successful with true") {
                    beforeEach {
                        wordBookService.checkIfOverlapSuccess = true
                        viewModel.checkIfOverlap()
                    }
                    it("should be true") {
                        expect(viewModel.isOverlapped).to(beTrue())
                    }
                    context("when meaningText is updated") {
                        beforeEach {
                            viewModel.meaningText = Random.string
                        }
                        it("should be nil") {
                            expect(viewModel.isOverlapped).to(beNil())
                        }
                    }
                }
                context("when checkIfOverlap is successful with false") {
                    beforeEach {
                        wordBookService.checkIfOverlapSuccess = false
                        viewModel.checkIfOverlap()
                    }
                    it("should be false") {
                        expect(viewModel.isOverlapped).to(beFalse())
                    }
                    context("when meaningText is updated") {
                        beforeEach {
                            viewModel.meaningText = Random.string
                        }
                        it("should be nil") {
                            expect(viewModel.isOverlapped).to(beNil())
                        }
                    }
                }
                context("when checkIfOverlap fails") {
                    beforeEach {
                        viewModel.checkIfOverlap()
                    }
                    it("should be nil") {
                        expect(viewModel.isOverlapped).to(beNil())
                    }
                }
            }
        }
        
        describe("overlapCheckButtonTitle") {
            beforeEach {
                prepare()
            }
            it("should be '중복체크' at first") {
                expect(viewModel.overlapCheckButtonTitle).to(equal("중복체크"))
            }
            context("when checkIfOverlap is successful with true") {
                beforeEach {
                    getWordBooksSuccessfully()
                    viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    wordBookService.checkIfOverlapSuccess = true
                    viewModel.checkIfOverlap()
                }
                it("should be '중복됨'") {
                    expect(viewModel.overlapCheckButtonTitle).to(equal("중복됨"))
                }
            }
            context("when checkIfOverlap is successful with false") {
                beforeEach {
                    getWordBooksSuccessfully()
                    viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    wordBookService.checkIfOverlapSuccess = false
                    viewModel.checkIfOverlap()
                }
                it("should be '중복 아님'") {
                    expect(viewModel.overlapCheckButtonTitle).to(equal("중복 아님"))
                }
            }
            context("when checkIfOverlap is failed") {
                beforeEach {
                    getWordBooksSuccessfully()
                    viewModel.selectedBookID = viewModel.bookList.randomElement()!.id
                    viewModel.checkIfOverlap()
                }
                it("should be '중복체크'") {
                    expect(viewModel.overlapCheckButtonTitle).to(equal("중복체크"))
                }
            }
        }
    }
    
}

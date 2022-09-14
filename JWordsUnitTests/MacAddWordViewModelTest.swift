//
//  MacAddWordViewModelTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/14.
//

import Quick
import Nimble
@testable import JWords

#if os(macOS)

class MacAddWordViewModelTest: QuickSpec {
    
    override func spec() {
        var viewModel: MacAddWordView.ViewModel!
        var dependency: MockDependency!
        var wordBookService: MockWordBookService!
        var wordService: MockWordService!
        var sampleService: MockSampleService!
        
        func prepare() {
            wordBookService = MockWordBookService()
            wordService = MockWordService()
            sampleService = MockSampleService()
            dependency = MockDependency(wordBookService: wordBookService, wordService: wordService, sampleService: sampleService)
            viewModel = MacAddWordView.ViewModel(dependency)
        }
        
        describe("meaningText") {
            
        }
        
        describe("meaningImage") {
            
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

#endif

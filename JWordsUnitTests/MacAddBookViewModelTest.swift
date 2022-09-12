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
        var wordBookService: WordBookService!
        
        func prepare() {
            wordBookService = MockWordBookService()
            viewModel = MacAddBookView.ViewModel(wordBookService: wordBookService)
        }
        
        describe("bookName") {
            
        }
        
        describe("isSaveButtonUnable") {
            
        }
        
    }
    
}


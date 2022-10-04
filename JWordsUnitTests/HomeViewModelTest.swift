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
        var viewModel: HomeView.ViewModel
        var wordBookService: MockWordBookService!
        
        func prepare() {
            wordBookService = MockWordBookService()
            viewModel = HomeView.ViewModel(wordBookService: wordBookService)
        }
        
        describe("") {
            
        }
        
    }
    
}

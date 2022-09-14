//
//  MockDependency.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/14.
//

@testable import JWords

class MockDependency: Dependency {
    
    let wordBookService: WordBookService
    let wordService: WordService
    let sampleService: SampleService

    init(wordBookService: WordBookService, wordService: WordService, sampleService: SampleService) {
        self.wordBookService = wordBookService
        self.wordService = wordService
        self.sampleService = sampleService
    }
}



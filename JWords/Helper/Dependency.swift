//
//  Dependency.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/06.
//

import Foundation

protocol Dependency {
    var wordBookService: WordService { get }
    var wordService: WordService { get }
    var sampleService: SampleService { get }
}


class DependencyImpl: Dependency {
    
    let wordBookService: WordBookService
    let wordSerivce: WordService
    let sampleService: SampleService
    
    init() {
        let db = FirestoreDB()
        let ic = ImageCompressorImpl()
        let iu = FirebaseIU(imageCompressor: ic)
        
        self.wordSerivce = WordServiceImpl(database: db, imageUploader: iu)
        self.wordBookService = WordBookServiceImpl(database: db, wordService: wordSerivce)
        self.sampleService = SampleServiceImpl(database: db)
    }
    
}

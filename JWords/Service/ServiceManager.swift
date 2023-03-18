//
//  Dependency.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/06.
//

import Foundation

class ServiceManager {
    static let shared: ServiceManager = ServiceManager()
    
    let wordBookService: WordBookService
    let wordService: WordService
    let sampleService: SampleService
    let todayService: TodayService
    
    init() {
        let db = FirestoreDB()
        let ic = ImageCompressorImpl()
        let iu = FirebaseIU(imageCompressor: ic)
        
        self.wordService = WordServiceImpl(database: db, imageUploader: iu)
        self.wordBookService = WordBookServiceImpl(database: db, wordService: wordService)
        self.sampleService = SampleServiceImpl(database: db)
        self.todayService = TodayServiceImpl(database: db)
    }
    

    
}

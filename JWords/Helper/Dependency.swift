//
//  Dependency.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/06.
//

class Dependency {
    
    let wordBookService: WordBookService
    let wordService: WordService
    let sampleService: SampleService
    
    init(database: Database) {
        let database = FirestoreDB()
        let imageCompressor = ImageCompressorImpl()
        let imageUploader = FirebaseIU(imageCompressor: imageCompressor)
        self.wordService = WordServiceImpl(database: database, imageUploader: imageUploader)
        self.wordBookService = WordBookServiceImpl(database: database, wordService: wordService)
        self.sampleService = SampleServiceImpl(database: database)
    }
}

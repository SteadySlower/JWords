//
//  Dependency.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/06.
//

class Dependency {
    
    private static let db = FirestoreDB()
    private static let ic = ImageCompressorImpl()
    private static let iu = FirebaseIU(imageCompressor: ic)

    static let wordBookService = WordBookServiceImpl(database: db, wordService: wordService)
    static let wordService = WordServiceImpl(database: db, imageUploader: iu)
    static let sampleService = SampleServiceImpl(database: db)
}

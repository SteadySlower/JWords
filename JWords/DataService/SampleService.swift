//
//  SampleService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

import Foundation

protocol SampleService {
    func saveSample(wordInput: WordInput)
    func getSamples(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>)
    func addOneToUsed(of sample: Sample)
}

class SampleServiceImpl: SampleService {
    
    let db: SampleDatabase
    
    init(database: SampleDatabase) {
        self.db = database
    }
    
    func saveSample(wordInput: WordInput) {
        db.insertSample(wordInput)
    }
    
    func getSamples(_ query: String, completionHandler: ([Sample]?, Error?) -> Void) {
        db.fetchSample(query, completionHandler: completionHandler)
    }
    
    func addOneToUsed(of sample: Sample) {
        db.updateUsed(of: sample, to: sample.used + 1)
    }
}

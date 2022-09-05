//
//  SampleService.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/05.
//

import Foundation

protocol SampleServiceProtocol {
    func saveSample(wordInput: WordInput)
    func getSamples(_ query: String, completionHandler: CompletionWithData<[Sample]>)
    func updateUsed(of example: Sample)
}

class SampleService: SampleServiceProtocol {
    func saveSample(wordInput: WordInput) {
        <#code#>
    }
    
    func getSamples(_ query: String, completionHandler: ([Sample]?, Error?) -> Void) {
        <#code#>
    }
    
    func updateUsed(of example: Sample) {
        <#code#>
    }
}

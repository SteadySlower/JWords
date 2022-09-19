//
//  MockSampleService.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/14.
//


@testable import JWords

class MockSampleService {
    var getSamplesSuccess: [Sample]?
}

extension MockSampleService: SampleService {
    func saveSample(wordInput: WordInput) {}

    func getSamples(_ query: String, completionHandler: @escaping CompletionWithData<[Sample]>) {
        guard let getSamplesSuccess = getSamplesSuccess else {
            let error = AppError.generic(massage: "Mock Error from MockSampleService.getSamples")
            completionHandler(nil, error)
            return
        }
        completionHandler(getSamplesSuccess, nil)
    }

    func addOneToUsed(of sample: Sample) {}


}

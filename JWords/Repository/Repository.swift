//
//  Repository.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Foundation
import SwiftUI
import Combine

class Repository {
    
    @Published private(set) var isLoading = false
    private let _error = PassthroughSubject<Error, Never>()
    var error: AnyPublisher<Error, Never> {
        _error.eraseToAnyPublisher()
    }
    
    var subscription: [AnyCancellable] = []
    
    final func updateIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    final func onError(_ error: Error) {
        _error.send(error)
    }
    
    func clear() {
        subscription = []
    }
    
}

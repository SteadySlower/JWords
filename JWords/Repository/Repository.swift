//
//  Repository.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Foundation
import SwiftUI
import Combine

protocol BaseRepository {
    var isLoading: AnyPublisher<Bool, Never> { get }
    var error: AnyPublisher<Error, Never> { get }
    var subscription: [AnyCancellable] { get }
    func clear() -> Void
}

class Repository: BaseRepository {
    
    private let _isLoading = CurrentValueSubject<Bool, Never>(false)
    
    private let _error = PassthroughSubject<Error, Never>()
    
    var isLoading: AnyPublisher<Bool, Never> {
        _isLoading.eraseToAnyPublisher()
    }
    
    var error: AnyPublisher<Error, Never> {
        _error.eraseToAnyPublisher()
    }
    
    var subscription: [AnyCancellable] = []
    
    final private func isLoading(_ isLoading: Bool) {
        _isLoading.send(isLoading)
        
    }
    
    final private func onError(_ error: Error) {
        _error.send(error)
    }
    
    func clear() {
        subscription = []
    }
    
}

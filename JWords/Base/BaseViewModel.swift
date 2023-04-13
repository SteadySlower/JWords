//
//  BaseViewModel.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Combine

class BaseViewModel: ObservableObject {
    
    var subscription = [AnyCancellable]()
    
    func clear() {
        subscription = []
    }
    
}

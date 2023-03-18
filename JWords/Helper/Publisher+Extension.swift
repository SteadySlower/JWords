//
//  Publisher+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//


import Combine
import Foundation

extension Publisher where Self.Failure == Never {
    func weakAssign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) where Root: BaseViewModel {
        return self.receive(on: RunLoop.main)
            .sink { [weak object] (value) in
            object?[keyPath: keyPath] = value
            }
            .store(in: &object.subscription)
    }
}

//
//  Array+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/08/26.
//

import Foundation

extension Array where Element: Hashable {
    func removeOverlapping() -> Self {
        Array(Set(self))
    }
}

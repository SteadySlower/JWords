//
//  Calendar+Extension.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/20.
//

import Foundation

extension Calendar {
    func getDateGap(from: Date, to: Date) -> Int {
        let fromDateOnly = from.onlyDate
        let toDateOnly = to.onlyDate
        return self.dateComponents([.day], from: fromDateOnly, to: toDateOnly).day ?? 0
    }
}

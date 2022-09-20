//
//  Date+Extension.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/20.
//

import Foundation

extension Date {
    var onlyDate: Date {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: component) ?? Date()
    }
}

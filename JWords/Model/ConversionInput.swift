//
//  ConversionInput.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import Foundation

struct ConversionInput: Equatable {
    
    let type: UnitType
    let kanjiText: String
    let kanjiImage: Data?
    let meaningText: String
    let meaningImage: Data?
    
}

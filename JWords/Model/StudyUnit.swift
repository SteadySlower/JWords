//
//  StudyUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation

struct StudyUnit: Equatable, Identifiable, Sendable {
    
    let id: String
    let studySetID: String
    let kanjiText: String
    let kanjiImageURL: String
    let meaningText: String
    let meaningImageURL: String
    var studyState: StudyState
    let createdAt: Date
    
}

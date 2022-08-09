//
//  Events.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/08.
//

import Combine

protocol Event {}

enum CellEvent: Event {
    case studyStateUpdate(id: String?, state: StudyState)
}

enum StudyViewEvent: Event {
    // 모든 단어가 앞면이 되어야 하면 nil
    case toFront(id: String?)
}

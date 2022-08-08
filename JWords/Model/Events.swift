//
//  Events.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/08.
//

import Combine

protocol Event { }

enum CellEvent: Event {
    case StudyStateUpdate(to: StudyState)
}

enum StudyViewEvent: Event {
    case toFront
}

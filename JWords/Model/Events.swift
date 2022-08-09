//
//  Events.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/08.
//

protocol Event {}

enum CellEvent: Event {
    case studyStateUpdate(id: String?, state: StudyState)
}

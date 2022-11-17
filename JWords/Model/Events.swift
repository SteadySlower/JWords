//
//  Events.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/08.
//

protocol Event {}

enum CellEvent: Event {
    case studyStateUpdate(word: Word, state: StudyState)
}

enum StudyViewEvent: Event {
    case toFront
}

enum WordInputViewEvent: Event {
    case wordEdited(word: Word, wordInput: WordInput)
}

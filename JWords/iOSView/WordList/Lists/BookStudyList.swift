//
//  StudyList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct StudyBook: ReducerProtocol {
    struct State: Equatable {
        let book: StudySet
        let _words: [StudyUnit]
        var words: IdentifiedArrayOf<StudyWord.State>
        
        init(book: StudySet, words: [StudyUnit]) {
            self.book = book
            self._words = words
            self.words = IdentifiedArray(uniqueElements: words.map { StudyWord.State(sample: $0) })
        }
        
        mutating func shuffleWords() {
            let shuffled = _words.shuffled()
            words = IdentifiedArray(uniqueElements: shuffled.map { StudyWord.State(sample: $0) })
        }
    }
    
    enum Action: Equatable {
        case word(id: StudyWord.State.ID, action: StudyWord.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.words, action: /Action.word(id:action:)) {
            StudyWord()
        }
    }
    
}

//
//  StudyWords.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct StudyWords: ReducerProtocol {
    struct State: Equatable {
        var words: IdentifiedArrayOf<StudyWord.State>
        
        init(words: [StudyUnit], frontType: FrontType, isLocked: Bool) {
            self.words = IdentifiedArray(
                uniqueElements: words.map {
                    StudyWord.State(unit: $0,
                                    frontType: frontType,
                                    isLocked: isLocked)
                }
            )
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

struct StudyList: View {
    
    let store: StoreOf<StudyWords>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEachStore(
                  self.store.scope(state: \.words, action: StudyWords.Action.word(id:action:))
                ) {
                    StudyCell(store: $0)
                }
            }
            .padding(.horizontal, Constants.Size.CELL_HORIZONTAL_PADDING)
            .padding(.vertical, 10)
        }
    }
    
}

#Preview {
    StudyList(store: Store(
        initialState: StudyWords.State(
            words: .mock,
            frontType: .kanji,
            isLocked: false
        ),
        reducer: StudyWords())
    )
}

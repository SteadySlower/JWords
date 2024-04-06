//
//  WritingKanjiCell.swift
//  JWords
//
//  Created by JW Moon on 2/3/24.
//

import SwiftUI
import ComposableArchitecture
import Model
import CommonUI

@Reducer
struct DisplayWritingKanji {
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: String { kanji.id }
        var kanji: Kanji
        var studyState: StudyState {
            get {
                kanji.studyState
            }
            set(newState) {
                kanji.studyState = newState
            }
        }
    }
    
    enum Action: Equatable {
        case select
        case updateStudyState(StudyState)
    }
    
    @Dependency(WritingKanjiClient.self) var wkClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateStudyState(let newState):
                state.studyState = try! wkClient.studyState(state.kanji, newState)
            default: return .none
            }
            return .none
        }
    }
}


struct WritingKanjiCell: View {
    
    let store: StoreOf<DisplayWritingKanji>
    @State private var dragAmount: CGSize = .zero
    
    var body: some View {
        SlidableCell(
            studyState: store.studyState,
            dragAmount: dragAmount)
        {
            Text(store.kanji.meaningText)
                .font(.system(size: 50))
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding(.horizontal, 5)
        }
        .addCellGesture(isLocked: false) { gesture in
            switch gesture {
            case .tapped:
                store.send(.select)
            case .doubleTapped:
                store.send(.updateStudyState(.undefined))
            case .dragging(let size):
                dragAmount.width = size.width
            case .draggedLeft:
                store.send(.updateStudyState(.success))
                dragAmount = .zero
            case .draggedRight:
                store.send(.updateStudyState(.fail))
                dragAmount = .zero
            }
        }
    }
}

#Preview {
    WritingKanjiCell(
        store: Store(
            initialState: DisplayWritingKanji.State(kanji: .init(index: 0)),
            reducer: { DisplayWritingKanji() }
        )
    )
    .frame(height: 100)
}

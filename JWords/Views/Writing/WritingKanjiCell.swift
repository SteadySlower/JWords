//
//  WritingKanjiCell.swift
//  JWords
//
//  Created by JW Moon on 2/3/24.
//

import SwiftUI
import ComposableArchitecture

struct DisplayWritingKanji: Reducer {
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
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}


struct WritingKanjiCell: View {
    
    let store: StoreOf<DisplayWritingKanji>
    @State var dragAmount: CGSize = .zero
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            SlidableCell(
                studyState: vs.studyState,
                dragAmount: dragAmount) 
            {
                Text(vs.kanji.meaningText)
                    .font(.system(size: 50))
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .padding(.horizontal, 5)
            }
            .addCellGesture(isLocked: false) { gesture in
                switch gesture {
                case .tapped:
                    vs.send(.select)
                case .doubleTapped:
                    vs.send(.updateStudyState(.undefined))
                case .dragging(let size):
                    dragAmount.width = size.width
                case .draggedLeft:
                    vs.send(.updateStudyState(.success))
                    dragAmount = .zero
                case .draggedRight:
                    vs.send(.updateStudyState(.fail))
                    dragAmount = .zero
                }
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

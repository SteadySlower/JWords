//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct StudyWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        var unit: StudyUnit
        let isLocked: Bool
        let frontType: FrontType
        var studyState: StudyState {
            get {
                unit.studyState
            }
            set(newState) {
                unit.studyState = newState
            }
        }
        var isFront: Bool = true
        
        var alert: AlertState<Action>?
        
        init(unit: StudyUnit, frontType: FrontType = .kanji, isLocked: Bool = false) {
            self.id = unit.id
            self.unit = unit
            self.isLocked = isLocked
            self.frontType = frontType
        }

    }
    
    enum SwipeDirection: Equatable {
        case left, right
    }
    
    enum Action: Equatable {
        case cellTapped
        case cellDoubleTapped
        case cellDrag(direction: SwipeDirection)
        case showErrorAlert
        case alertDismissed
    }
    
    @Dependency(\.cdWordClient) var wordClient
    private enum UpdateStudyStateID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                state.isFront.toggle()
                return .none
            case .cellDoubleTapped:
                if state.isLocked { return .none }
                let beforeState = state.studyState
                state.studyState = .undefined
                do {
                    _ = try wordClient.studyState(state.unit, .undefined)
                } catch {
                    state.studyState = beforeState
                    return .task { .showErrorAlert }
                }
                return .none
            case .cellDrag(let direction):
                if state.isLocked { return .none }
                let beforeState = state.studyState
                let newState: StudyState = direction == .left ? .success : .fail
                state.studyState = newState
                do {
                    _ = try wordClient.studyState(state.unit, newState)
                } catch {
                    state.studyState = beforeState
                    return .task { .showErrorAlert }
                }
                return .none
            case .showErrorAlert:
                state.alert = AppError.unknown.simpleAlert(action: Action.self)
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            }
        }
    }

}

struct StudyCell: View {
    
    let store: StoreOf<StudyWord>
    
    @GestureState private var dragAmount = CGSize.zero
    
    // gestures
    let dragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .global)
    let tapGesture = TapGesture()
    let doubleTapGesture = TapGesture(count: 2)
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            BaseCell(unit: vs.unit,
                     frontType: vs.frontType,
                     isFront: vs.isFront,
                     dragAmount: dragAmount)
            .gesture(dragGesture
                .updating($dragAmount) { dragUpdating(vs.isLocked, $0, &$1, &$2) }
                .onEnded { vs.send(.cellDrag(direction: $0.translation.width > 0 ? .left : .right)) }
            )
            .gesture(doubleTapGesture.onEnded { vs.send(.cellDoubleTapped) })
            .gesture(tapGesture.onEnded { vs.send(.cellTapped) })
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
    
}


// MARK: View Methods

extension StudyCell {
    
    private func dragUpdating(_ isLocked: Bool, _ value: _EndedGesture<DragGesture>.Value, _ state: inout CGSize, _ transaction: inout Transaction) {
        if isLocked { return }
        state.width = value.translation.width
    }
    
}

struct StudyCell_Previews: PreviewProvider {
    
    static var previews: some View {
        StudyCell(
            store: Store(
                initialState: StudyWord.State(unit: .init(index: 0), frontType: .meaning),
                reducer: StudyWord()._printChanges()
            )
        )
        StudyCell(
            store: Store(
                initialState: StudyWord.State(unit: .init(index: 0), frontType: .kanji, isLocked: true),
                reducer: StudyWord()._printChanges()
            )
        )
        .previewDisplayName("Locked")
    }
}

//
//  WordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct StudyOneUnit {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: String
        var unit: StudyUnit
        let isLocked: Bool
        let frontType: FrontType
        var kanjis: [Kanji] = []
        var studyState: StudyState {
            get {
                unit.studyState
            }
            set(newState) {
                unit.studyState = newState
            }
        }
        var isFront: Bool = true
        var showKanjis: Bool {
            get {
                !kanjis.isEmpty
            }
            set(bool) {
                if !bool {
                    kanjis = []
                }
            }
        }
        
        init(unit: StudyUnit, frontType: FrontType = .kanji, isLocked: Bool = false) {
            self.id = unit.id
            self.unit = unit
            self.isLocked = isLocked
            self.frontType = frontType
        }

    }
    
    @Dependency(StudyUnitClient.self) var unitClient
    @Dependency(KanjiClient.self) var kanjiClient
    
    enum Action: Equatable {
        case toggleFront
        case updateStudyState(StudyState)
        case showKanjis
    }
    
    private let cd = CoreDataService.shared
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleFront:
                state.isFront.toggle()
            case .updateStudyState(let studyState):
                if state.isLocked { break }
                state.studyState = try! unitClient.studyState(state.unit, studyState)
            case .showKanjis:
                if state.kanjis.isEmpty {
                    state.kanjis = try! kanjiClient.unitKanjis(state.unit)
                } else {
                    state.kanjis = []
                }
            }
            return .none
        }
    }

}

struct StudyCell: View {
    
    typealias VS = ViewStore<StudyOneUnit.State, StudyOneUnit.Action>
    
    let store: StoreOf<StudyOneUnit>
    
    @State private var dragAmount = CGSize.zero
    
    // gestures
    let dragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .global)
    let tapGesture = TapGesture()
    let doubleTapGesture = TapGesture(count: 2)
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            BaseCell(unit: store.unit, frontType: store.frontType, isFront: store.isFront, dragAmount: dragAmount)
            .overlay(showKanjisButton)
            if store.showKanjis {
                kanjiList
                    .opacity(store.isFront ? 0 : 1)
                    .padding(.top, 5)
            }
        }
        .addCellGesture(isLocked: store.isLocked) { gesture in
            switch gesture {
            case .tapped:
                store.send(.toggleFront)
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
    
    private var showKanjisButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    store.send(.showKanjis)
                } label: {
                    Text("漢 ") + Text(store.showKanjis ? "🔼" : "🔽")
                }
                .font(.system(size: 24))
                .padding([.bottom, .trailing], 8)
            }
        }
        .hide(dragAmount != .zero)
        .hide(store.isFront)
    }
    
    private func kanjiCell(_ kanji: Kanji) -> some View {
        VStack(spacing: 2) {
            Text(kanji.kanjiText)
                .font(.system(size: 70))
            if !kanji.meaningText.isEmpty {
                Text(kanji.meaningText)
                    .font(.system(size: 20))
            } else {
                Text("???")
                    .font(.system(size: 20))
            }
        }
        .padding([.horizontal, .bottom], 2)
        .defaultRectangleBackground()
    }
    
    private var kanjiList: some View {
        FlexBox(horizontalSpacing: 5, verticalSpacing: 5, alignment: .center) {
            ForEach(store.kanjis, id: \.id) { kanjiCell($0) }
        }
    }
    
}

struct StudyCell_Previews: PreviewProvider {
    
    static var previews: some View {
        StudyCell(
            store: Store(
                initialState: StudyOneUnit.State(unit: .init(index: 0), frontType: .meaning),
                reducer: { StudyOneUnit()._printChanges() }
            )
        )
        StudyCell(
            store: Store(
                initialState: StudyOneUnit.State(unit: .init(index: 0), frontType: .kanji, isLocked: true),
                reducer: { StudyOneUnit()._printChanges() }
            )
        )
        .previewDisplayName("Locked")
    }
}

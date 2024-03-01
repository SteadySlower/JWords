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
    struct State: Equatable, Identifiable {
        let id: String
        var unit: StudyUnit
        let isLocked: Bool
        let frontType: FrontType
        var kanjis: [Kanji] = []
        let showKanjiButton: Bool
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
            self.showKanjiButton = {
                guard unit.type != .kanji else { return false }
                return HuriganaConverter.shared.extractKanjis(from: unit.kanjiText).count == 0 ? false : true
            }()
        }

    }
    
    @Dependency(\.studyUnitClient) var unitClient
    @Dependency(\.kanjiClient) var kanjiClient
    
    enum Action: Equatable {
        case toggleFront
        case updateStudyState(StudyState)
        case kanjiButtonTapped
    }
    
    private let cd = CoreDataService.shared
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleFront:
                state.isFront.toggle()
                return .none
            case .updateStudyState(let studyState):
                if state.isLocked { return .none }
                state.studyState = try! unitClient.studyState(state.unit, studyState)
                return .none
            case .kanjiButtonTapped:
                if state.kanjis.isEmpty {
                    state.kanjis = try! kanjiClient.unitKanjis(state.unit)
                } else {
                    state.kanjis = []
                }
                return .none
            }
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
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 0) {
                BaseCell(unit: vs.unit,
                         frontType: vs.frontType,
                         isFront: vs.isFront,
                         dragAmount: dragAmount)
                .overlay(
                    showKanjisButton(vs)
                )
                if vs.showKanjis {
                    kanjiList(vs)
                        .opacity(vs.isFront ? 0 : 1)
                        .padding(.top, 5)
                }
            }
            .addCellGesture(isLocked: vs.isLocked) { gesture in
                switch gesture {
                case .tapped:
                    vs.send(.toggleFront)
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
    
    private func showKanjisButton(_ vs: VS) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    vs.send(.kanjiButtonTapped)
                } label: {
                    Text("漢 ") + Text(vs.showKanjis ? "🔼" : "🔽")
                }
                .font(.system(size: 24))
                .padding([.bottom, .trailing], 8)
            }
        }
        .hide(dragAmount != .zero)
        .hide(vs.isFront)
        .hide(!vs.showKanjiButton)
    }
    
    private func kanjiCell(_ kanji: Kanji, _ vs: VS) -> some View {
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
    
    private func kanjiList(_ vs: VS) -> some View {
        FlexBox(horizontalSpacing: 5, verticalSpacing: 5, alignment: .center) {
            ForEach(vs.kanjis, id: \.id) { kanji in
                kanjiCell(kanji, vs)
            }
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

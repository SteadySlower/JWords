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
        
        var alert: AlertState<Action>?
        var toEditKanji: AddingUnit.State?
        
        var showEditModal: Bool {
            toEditKanji != nil
        }
        
        init(unit: StudyUnit, frontType: FrontType = .kanji, isLocked: Bool = false) {
            self.id = unit.id
            self.unit = unit
            self.isLocked = isLocked
            self.frontType = frontType
            self.showKanjiButton = {
                guard unit.type != .kanji else { return false }
                return HuriganaConverter.shared.extractKanjis(from: unit.kanjiText ?? "").count == 0 ? false : true
            }()
        }

    }
    
    enum SwipeDirection: Equatable {
        case left, right
    }
    
    enum Action: Equatable {
        case cellTapped
        case cellDoubleTapped
        case cellDrag(direction: SwipeDirection)
        case addKanjiMeaningTapped(Kanji)
        case showErrorAlert
        case alertDismissed
        case kanjiButtonTapped
        case editKanji(action: AddingUnit.Action)
        case setKanjiEditModal(isPresented: Bool)
    }
    
    private let cd = CoreDataClient.shared
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
            case .kanjiButtonTapped:
                if state.kanjis.isEmpty {
                    state.kanjis = try! cd.fetchKanjis(usedIn: state.unit)
                } else {
                    state.kanjis = []
                }
                return .none
            case .addKanjiMeaningTapped(let kanji):
                state.toEditKanji = AddingUnit.State(mode: .editKanji(kanji: kanji))
                return .none
            case .editKanji(let action):
                switch action {
                case .kanjiEdited(let kanji):
                    guard let index = state.kanjis.firstIndex(where: { $0.id == kanji.id }) else { return .none }
                    state.kanjis[index] = kanji
                    state.toEditKanji = nil
                    return .none
                case .cancelButtonTapped:
                    state.toEditKanji = nil
                    return .none
                default:
                    return .none
                }
            default:
                return .none
            }
        }
        .ifLet(\.toEditKanji, action: /Action.editKanji(action:)) {
            AddingUnit()
        }
    }

}

struct StudyCell: View {
    
    typealias VS = ViewStore<StudyWord.State, StudyWord.Action>
    
    let store: StoreOf<StudyWord>
    
    @GestureState private var dragAmount = CGSize.zero
    
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
                if vs.showKanjis {
                    kanjiList(vs)
                        .opacity(vs.isFront ? 0 : 1)
                }
            }
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
            .sheet(isPresented: vs.binding(
                get: \.showEditModal,
                send: StudyWord.Action.setKanjiEditModal(isPresented:))
            ) {
                IfLetStore(self.store.scope(state: \.toEditKanji, action: StudyWord.Action.editKanji(action:))) {
                    StudyUnitAddView(store: $0)
                }
            }
            .overlay(
                showKanjisButton(vs)
            )
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
                        .font(.title3)
                }
                .padding(.bottom, vs.showKanjis ? 0 : 8)
                .padding(.trailing, vs.showKanjis ? 0 : 8)

            }
        }
        .hide(dragAmount != .zero)
        .hide(vs.isFront)
        .hide(!vs.showKanjiButton)
    }
    
    private func kanjiList(_ vs: VS) -> some View {
        VStack {
            ForEach(vs.kanjis, id: \.id) { kanji in
                if let meaningText = kanji.meaningText {
                    Text("\(kanji.kanjiText ?? ""): \(meaningText)")
                } else {
                    Button("\(kanji.kanjiText ?? ""): (뜻 추가하기)") { vs.send(.addKanjiMeaningTapped(kanji)) }
                }
            }
        }
        .font(.system(size: 24))
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

//
//  WordMoveView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI
import ComposableArchitecture

struct MoveUnits: Reducer {
    struct State: Equatable {
        let fromSet: StudySet
        let isReviewSet: Bool
        let toMoveUnits: [StudyUnit]
        var sets = [StudySet]()
        var selectedID: String? = nil
        var willCloseSet: Bool
        
        init(
            fromSet: StudySet,
            isReviewSet: Bool,
            toMoveUnits: [StudyUnit],
            willCloseSet: Bool
        ) {
            self.fromSet = fromSet
            self.isReviewSet = isReviewSet
            self.toMoveUnits = toMoveUnits
            self.willCloseSet = willCloseSet
        }
        
        var selectedSet: StudySet? {
            if let selectedID = selectedID {
                return sets.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
    }
    
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    enum Action: Equatable {
        case onAppear
        case updateSelection(String?)
        case updateWillClose(Bool)
        case closeButtonTapped
        case cancelButtonTapped
        case onMoved
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.sets = try! setClient.fetch(false).filter { $0.id != state.fromSet.id }
                return .none
            case .updateSelection(let id):
                state.selectedID = id
                return .none
            case .updateWillClose(let willClose):
                state.willCloseSet = willClose
                return .none
            case .closeButtonTapped:
                if let toSet = state.selectedSet {
                    try! unitClient.move(state.toMoveUnits, state.fromSet, toSet)
                }
                if state.willCloseSet {
                    try! setClient.close(state.fromSet)
                }
                if state.isReviewSet {
                    scheduleClient.reviewed(state.fromSet)
                }
                return .send(.onMoved)
            default:
                return .none
            }
        }
    }
}

struct UnitMoveView: View {
    let store: StoreOf<MoveUnits>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 20) {
                Text("\(vs.toMoveUnits.count)개의 단어 이동하기")
                    .font(.system(size: 35))
                    .bold()
                VStack {
                    Text("단어장 선택")
                        .font(.system(size: 20))
                        .bold()
                        .leadingAlignment()
                        .padding(.leading, 10)
                    Picker("이동할 단어장 고르기", selection: vs.binding(
                        get: \.selectedID,
                        send: MoveUnits.Action.updateSelection)
                    ) {
                        Text(vs.sets.isEmpty ? "로딩중" : "이동 안함")
                            .tag(nil as String?)
                        ForEach(vs.sets, id: \.id) {
                            Text($0.title)
                                .tag($0.id as String?)
                        }
                    }
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #endif
                }
                VStack {
                    Toggle("현재 단어장 마감",
                        isOn: vs.binding(
                            get: \.willCloseSet,
                            send: MoveUnits.Action.updateWillClose)
                    )
                    .tint(.black)
                }
                if vs.isReviewSet {
                    Text("현재 단어장은 복습 리스트에 있습니다.\n단어를 이동하면 복습 리스트에서 제외됩니다.")
                }
                HStack {
                    button("취소", foregroundColor: .black) {
                        vs.send(.cancelButtonTapped)
                    }
                    button("확인", foregroundColor: .black) {
                        vs.send(.closeButtonTapped)
                    }
                }
            }
            .padding(.horizontal, 10)
            .onAppear { vs.send(.onAppear) }
        }
    }
    
    private func button(_ text: String, foregroundColor: Color, onTapped: @escaping () -> Void) -> some View {
        Button {
            onTapped()
        } label: {
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(foregroundColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .defaultRectangleBackground()
        }
    }
}

#Preview {
    UnitMoveView(
        store: Store(
            initialState: MoveUnits.State(
                fromSet: StudySet(index: 0),
                isReviewSet: true,
                toMoveUnits: .mock,
                willCloseSet: false
            ),
            reducer: { MoveUnits()._printChanges() }
        )
    )
}

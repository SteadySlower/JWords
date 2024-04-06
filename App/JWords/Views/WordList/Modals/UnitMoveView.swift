//
//  WordMoveView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI
import ComposableArchitecture
import Model
import CommonUI

@Reducer
struct MoveUnits {
    @ObservableState
    struct State: Equatable {
        let fromSet: StudySet
        let isReviewSet: Bool
        let toMoveUnits: [StudyUnit]
        var sets = [StudySet]()
        var selectedID: String? = nil
        var willCloseSet: Bool
        
        init(
            fromSet: StudySet,
            selectedID: String? = nil,
            isReviewSet: Bool,
            toMoveUnits: [StudyUnit],
            willCloseSet: Bool,
            sets: [StudySet] = []
        ) {
            self.fromSet = fromSet
            self.selectedID = selectedID
            self.isReviewSet = isReviewSet
            self.toMoveUnits = toMoveUnits
            self.willCloseSet = willCloseSet
            self.sets = sets
        }
        
        var selectedSet: StudySet? {
            if let selectedID = selectedID {
                return sets.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
    }
    
    @Dependency(ScheduleClient.self) var scheduleClient
    @Dependency(StudySetClient.self) var setClient
    @Dependency(StudyUnitClient.self) var unitClient
    @Dependency(\.dismiss) var dismiss
    
    enum Action: Equatable {
        case fetchSets
        case setSelectedID(String?)
        case setWillClose(Bool)
        case close
        case cancel
        case onMoved
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                state.sets = try! setClient.fetch(false).filter { $0.id != state.fromSet.id }
                return .none
            case .setSelectedID(let id):
                state.selectedID = id
                return .none
            case .setWillClose(let willClose):
                state.willCloseSet = willClose
                return .none
            case .close:
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
            case .cancel:
                return .run { _ in await self.dismiss() }
            default:
                return .none
            }
        }
    }
}

struct UnitMoveView: View {
    
    @Bindable var store: StoreOf<MoveUnits>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(store.toMoveUnits.count)개의 단어 이동하기")
                .font(.system(size: 35))
                .bold()
            VStack {
                Text("단어장 선택")
                    .font(.system(size: 20))
                    .bold()
                    .leadingAlignment()
                    .padding(.leading, 10)
                Picker("이동할 단어장 고르기", selection: $store.selectedID.sending(\.setSelectedID)) {
                    Text(store.sets.isEmpty ? "로딩중" : "이동 안함")
                        .tag(nil as String?)
                    ForEach(store.sets, id: \.id) {
                        Text($0.title)
                            .tag($0.id as String?)
                    }
                }
                #if os(iOS)
                .pickerStyle(.wheel)
                #endif
            }
            VStack {
                Toggle("현재 단어장 마감", isOn: $store.willCloseSet.sending(\.setWillClose))
                .tint(.black)
            }
            if store.isReviewSet {
                Text("현재 단어장은 복습 리스트에 있습니다.\n단어를 이동하면 복습 리스트에서 제외됩니다.")
            }
            HStack {
                button("취소", foregroundColor: .black) {
                    store.send(.cancel)
                }
                button("확인", foregroundColor: .black) {
                    store.send(.close)
                }
            }
        }
        .padding(.horizontal, 10)
        .onAppear { store.send(.fetchSets) }
    }
    
    private func button(_ text: String, foregroundColor: Color, onTapped: @escaping () -> Void) -> some View {
        Button {
            onTapped()
        } label: {
            Text(text.localize())
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

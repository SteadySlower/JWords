//
//  AddKanjiToSet.swift
//  JWords
//
//  Created by Jong Won Moon on 11/17/23.
//

import SwiftUI
import ComposableArchitecture

struct AddKanjiToSet: Reducer {
    struct State: Equatable {
        let kanji: Kanji
        var sets = [StudySet]()
        var selectedID: String? = nil
        
        var selectedSet: StudySet? {
            if let selectedID = selectedID {
                return sets.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
    }
    
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.kanjiClient) var kanjiClient
    
    enum Action: Equatable {
        case fetchSets
        case updateSelection(String?)
        case add
        case close
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                state.sets = try! setClient.fetch(false)
                return .none
            case .updateSelection(let id):
                state.selectedID = id
                return .none
            case .add:
                guard let set = state.selectedSet else { return .none }
                try! kanjiClient.addToSet(state.kanji, set)
                return .send(.close)
            default:
                return .none
            }
        }
    }
}

struct AddKanjiInSetModal: View {
    let store: StoreOf<AddKanjiToSet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 20) {
                Text("\(vs.kanji.kanjiText)를 단어장에 추가하기")
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
                        send: AddKanjiToSet.Action.updateSelection)
                    ) {
                        Text(vs.sets.isEmpty ? "로딩중" : "추가 안함")
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
                HStack {
                    button("취소", foregroundColor: .black) {
                        vs.send(.close)
                    }
                    button("추가", foregroundColor: .black) {
                        vs.send(.add)
                    }
                }
            }
            .padding(.horizontal, 10)
            .onAppear { vs.send(.fetchSets) }
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
    AddKanjiInSetModal(
        store: Store(
            initialState: AddKanjiToSet.State(kanji: .init(index: 0)),
            reducer: { AddKanjiToSet() }
        )
    )
}

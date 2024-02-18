//
//  AddWritingKanji.swift
//  JWords
//
//  Created by JW Moon on 2/12/24.
//

import SwiftUI
import ComposableArchitecture

struct AddWritingKanji: Reducer {
    struct State: Equatable {
        let kanji: Kanji
        let kanjiSets: [KanjiSet]
        var selectedID: String?
        
        var selectedSet: KanjiSet? {
            kanjiSets.first(where: { $0.id == selectedID })
        }
    }
    
    enum Action: Equatable {
        case updateID(String?)
        case add
        case cancel
        case added(KanjiSet)
    }
    
    @Dependency(\.kanjiSetClient) var kanjiSetClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateID(let id):
                state.selectedID = id
                return .none
            case .add:
                guard let toAddSet = state.selectedSet else { return .none }
                let addedSet = try! kanjiSetClient.addKanji(state.kanji, toAddSet)
                return .send(.added(addedSet))
            case .cancel:
                return .none
            case .added:
                // TODO: add logic
                return .none
            }
        }
    }
}

struct AddWritingKanjiView: View {
    
    let store: StoreOf<AddWritingKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                picker(
                    kanji: vs.kanji,
                    sets: vs.kanjiSets,
                    selectedID: vs.binding(
                        get: \.selectedID,
                        send: AddWritingKanji.Action.updateID
                    )
                )
                buttons(
                    isOKButtonAble: vs.selectedID != nil,
                    addButtonTapped: { vs.send(.add) },
                    cancelButtonTapped: { vs.send(.cancel) }
                )
            }
            .presentationDetents([.medium])
        }
    }
}

extension AddWritingKanjiView {
    
    private func picker(kanji: Kanji, sets: [KanjiSet], selectedID: Binding<String?>) -> some View {
        VStack {
            Text("\(kanji.kanjiText)를 추가할 한자쓰기장을 골라주세요.")
            Picker("한자 쓰기장 고르기", selection: selectedID) {
                Text("선택되지 않음")
                    .tag(nil as String?)
                ForEach(sets, id: \.id) { set in
                    Text(set.title)
                        .tag(set.id as String?)
                }
            }
            .tint(.black)
            #if os(iOS)
            .pickerStyle(.wheel)
            #endif
        }
    }
    
    func buttons(
        isOKButtonAble: Bool,
        addButtonTapped: @escaping () -> Void,
        cancelButtonTapped: @escaping () -> Void
    ) -> some View {
        HStack {
            HStack {
                Spacer()
                Button("취소") {
                    cancelButtonTapped()
                }
                .buttonStyle(InputButtonStyle())
                Spacer()
                Button("추가") {
                    addButtonTapped()
                }
                .buttonStyle(InputButtonStyle(isAble: isOKButtonAble))
                .disabled(!isOKButtonAble)
                Spacer()
            }
        }
    }
    
}

#Preview {
    AddWritingKanjiView(store: Store.init(
        initialState: AddWritingKanji.State(
            kanji: .init(index: 0),
            kanjiSets: .mock
        ), reducer: {
            AddWritingKanji()._printChanges()
        })
    )
}

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
    }
    
    enum Action: Equatable {
        case updateID(String?)
    }
    
    @Dependency(\.kanjiSetClient) var kanjiSetClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateID(let id):
                state.selectedID = id
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
                    sets: vs.kanjiSets,
                    selectedID: vs.binding(
                        get: \.selectedID,
                        send: AddWritingKanji.Action.updateID
                    )
                )
            }
        }
    }
}

extension AddWritingKanjiView {
    
    private func picker(sets: [KanjiSet], selectedID: Binding<String?>) -> some View {
        VStack {
            Text("이 한자를 추가할 한자쓰기장을 골라주세요.")
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
    
}

#Preview {
    AddWritingKanjiView(store: Store.init(
        initialState: AddWritingKanji.State(
            kanji: .init(index: 0),
            kanjiSets: .mock
        ), reducer: {
            AddWritingKanji()
        })
    )
}

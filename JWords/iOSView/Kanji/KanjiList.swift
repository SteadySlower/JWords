//
//  KanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture

struct KanjiList: ReducerProtocol {
    struct State: Equatable {
        var kanjis: [Kanji] = []
        var wordList: WordList.State?
        
        var showStudyView: Bool {
            wordList != nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case editKanji(kanji: Kanji, meaningText: String)
        case wordButtonTapped(in: Kanji)
        case wordList(action: WordList.Action)
        case showStudyView(Bool)
    }
    
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.kanjis = try! cd.fetchAllKanjis()
                return .none
            case let .editKanji(kanji, meaningText):
                let edited = try! cd.editKanji(kanji: kanji, meaningText: meaningText)
                guard let index = state.kanjis.firstIndex(of: kanji) else { return .none }
                state.kanjis[index] = edited
                return .none
            case let .wordButtonTapped(kanji):
                let words = try! cd.fetchSampleUnit(ofKanji: kanji)
                state.wordList = WordList.State(kanji: kanji, units: words)
                return .none
            case .showStudyView(let isPresent):
                if !isPresent {
                    state.wordList = nil
                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.wordList, action: /Action.wordList(action:)) {
            WordList()
        }
    }

}

struct KanjiListView: View {
    
    let store: StoreOf<KanjiList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.wordList,
                                action: KanjiList.Action.wordList(action:))
                            ) { StudyView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyView,
                                send: KanjiList.Action.showStudyView))
                { EmptyView() }
                LazyVStack {
                    ForEach(vs.kanjis, id: \.id) { kanji in
                        KanjiCell(kanji: kanji,
                                  editKanjiMeaning: { vs.send(.editKanji(kanji: $0, meaningText: $1)) },
                                  wordButtonTapped: { vs.send(.wordButtonTapped(in: kanji)) })
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}

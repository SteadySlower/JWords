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
        var kanjis: IdentifiedArrayOf<StudyKanji.State> = []
        var wordList: WordList.State?
        
        var showStudyView: Bool {
            wordList != nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case studyKanji(id: StudyKanji.State.ID, action: StudyKanji.Action)
        case wordList(action: WordList.Action)
        case showStudyView(Bool)
    }
    
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.kanjis = IdentifiedArrayOf(
                    uniqueElements: try! cd.fetchAllKanjis().map {
                        StudyKanji.State(kanji: $0)
                    })
                return .none
            case let .studyKanji(id, action):
                switch action {
                case let .onKanjiEdited(kanji):
                    guard let index = state.kanjis.index(id: id) else { return .none }
                    state.kanjis.update(StudyKanji.State(kanji: kanji), at: index)
                    return .none
                case .wordButtonTapped:
                    guard let index = state.kanjis.index(id: id) else { return .none }
                    let kanji = state.kanjis[index].kanji
                    let words = try! cd.fetchSampleUnit(ofKanji: kanji)
                    state.wordList = WordList.State(kanji: kanji, units: words)
                    return .none
                default:
                    return .none
                }
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
        .forEach(\.kanjis, action: /Action.studyKanji(id:action:)) {
            StudyKanji()
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
                    ForEachStore(
                      self.store.scope(state: \.kanjis, action: KanjiList.Action.studyKanji(id:action:))
                    ) {
                        KanjiCell(store: $0)
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}

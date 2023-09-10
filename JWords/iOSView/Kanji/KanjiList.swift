//
//  KanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture



struct KanjiList: ReducerProtocol {
    // FIXME: move it to proper place
    static let NUMBER_OF_KANJI_IN_A_PAGE = 20
    
    struct State: Equatable {
        var kanjis: [Kanji] = []
        var wordList: WordList.State?
        var isLastPage = false
        
        var showStudyView: Bool {
            wordList != nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchKanjis
        case kanjiCellTapped(Kanji)
        case wordList(action: WordList.Action)
        case showStudyView(Bool)
    }
    
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { .fetchKanjis }
            case .fetchKanjis:
                let last = state.kanjis.last
                let fetched = try! cd.fetchAllKanjis(after: last)
                if fetched.count < KanjiList.NUMBER_OF_KANJI_IN_A_PAGE { state.isLastPage = true }
                let moreArray = state.kanjis + fetched
                state.kanjis = moreArray
                return .none
            case .kanjiCellTapped(let kanji):
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
            VStack {
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
                ScrollView {
                    LazyVStack {
                        ForEach(vs.kanjis, id: \.id) { kanji in
                            Button {
                                vs.send(.kanjiCellTapped(kanji))
                            } label: {
                                KanjiCell(kanji: kanji)
                            }
                            .foregroundColor(.black)
                        }
                        if !vs.isLastPage {
                            ProgressView()
                                .foregroundColor(.gray)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        vs.send(.fetchKanjis)
                                    }
                                }
                        }
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
            .navigationTitle("한자 모아보기")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

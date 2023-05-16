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
    
    enum KanjiListFilter: Equatable, CaseIterable {
        case all, meaningless
        
        var pickerText: String {
            switch self {
            case .all: return "전부"
            case .meaningless: return "뜻 없음"
            }
        }
    }
    
    struct State: Equatable {
        var kanjis: IdentifiedArrayOf<StudyKanji.State> = []
        var wordList: WordList.State?
        var isLastPage = false
        var filter: KanjiListFilter = .all
        
        var showStudyView: Bool {
            wordList != nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchKanjis
        case setFilter(KanjiListFilter)
        case studyKanji(id: StudyKanji.State.ID, action: StudyKanji.Action)
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
                let last = state.kanjis.last?.kanji
                let fetched = try! cd.fetchAllKanjis(after: last)
                if fetched.count < KanjiList.NUMBER_OF_KANJI_IN_A_PAGE { state.isLastPage = true }
                let moreArray = state.kanjis.map { $0.kanji } + fetched
                state.kanjis = IdentifiedArrayOf(
                    uniqueElements: moreArray.map {
                        StudyKanji.State(kanji: $0)
                    })
                return .none
            case let .setFilter(filter):
                state.filter = filter
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
            VStack {
                Picker("", selection: vs.binding(
                    get: \.filter,
                    send: KanjiList.Action.setFilter)
                ) {
                    ForEach(KanjiList.KanjiListFilter.allCases, id: \.self) {
                        Text($0.pickerText)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
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
                        ForEachStore(
                          self.store.scope(state: \.kanjis, action: KanjiList.Action.studyKanji(id:action:))
                        ) {
                            KanjiCell(store: $0)
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
        }
    }
}

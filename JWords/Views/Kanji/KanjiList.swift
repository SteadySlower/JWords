//
//  KanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture



struct KanjiList: Reducer {
    // FIXME: move it to proper place
    static let NUMBER_OF_KANJI_IN_A_PAGE = 20
    
    struct State: Equatable {
        var kanjis: IdentifiedArrayOf<DisplayKanji.State>
        var studyKanjiSamples: StudyKanjiSamples.State?
        var isLastPage = false
        var searchKanji = SearchKanji.State()
        var edit: EditKanji.State?
        
        var showStudyView: Bool {
            studyKanjiSamples != nil
        }
        
        var showEditModal: Bool {
            edit != nil
        }
        
        var isSearching: Bool {
            !searchKanji.query.isEmpty
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchKanjis
        case kanjiCellTapped(Kanji)
        case studyKanjiSamples(StudyKanjiSamples.Action)
        case showStudyView(Bool)
        case searchKanji(SearchKanji.Action)
        case kanji(DisplayKanji.State.ID, DisplayKanji.Action)
        case showEditView(Bool)
        case edit(EditKanji.Action)
    }
    
    @Dependency(\.kanjiClient) var kanjiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isSearching else { return .none }
                return .send(.fetchKanjis)
            case .fetchKanjis:
                let last = state.kanjis.last
                let fetched = try! kanjiClient.fetch(last?.kanji)
                if fetched.count < KanjiList.NUMBER_OF_KANJI_IN_A_PAGE { state.isLastPage = true }
                state.kanjis.append(contentsOf:
                    IdentifiedArray(
                        uniqueElements: fetched.map { DisplayKanji.State(kanji: $0) }
                    )
                )
                return .none
            case let .kanji(_, action):
                switch action {
                case .showSamples(let kanji):
                    let units = try! kanjiClient.kanjiUnits(kanji)
                    state.studyKanjiSamples = StudyKanjiSamples.State(kanji: kanji, units: units)
                    return .none
                case .edit(let kanji):
                    state.edit = EditKanji.State(kanji)
                    return .none
                }
            case .showStudyView(let isPresent):
                if !isPresent {
                    state.studyKanjiSamples = nil
                }
                return .none
            case .showEditView(let isPresent):
                if !isPresent { state.edit = nil }
                return .none
            case .searchKanji(let action):
                switch action {
                case .updateQuery(let query):
                    if query.isEmpty {
                        return .send(.fetchKanjis)
                    } else {
                        return .none
                    }
                case .kanjiSearched(let kanjis):
                    state.kanjis = IdentifiedArray(uniqueElements: kanjis.map { DisplayKanji.State(kanji: $0) })
                    return .none
                }
            default:
                return .none
            }
        }
        .forEach(\.kanjis, action: /Action.kanji) {
            DisplayKanji()
        }
        .ifLet(\.studyKanjiSamples, action: /Action.studyKanjiSamples) {
            StudyKanjiSamples()
        }
        .ifLet(\.edit, action: /Action.edit) {
            EditKanji()
        }
        Scope(
            state: \.searchKanji,
            action: /Action.searchKanji,
            child: { SearchKanji() }
        )
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
                                state: \.studyKanjiSamples,
                                action: KanjiList.Action.studyKanjiSamples)
                            ) { StudyKanjiSampleView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyView,
                                send: KanjiList.Action.showStudyView))
                { EmptyView() }
                KanjiSearchBar(
                    store: store.scope(
                        state: \.searchKanji,
                        action: KanjiList.Action.searchKanji)
                )
                ScrollView {
                    LazyVStack {
                        ForEachStore(store.scope(
                            state: \.kanjis,
                            action: KanjiList.Action.kanji)
                        ) {
                            KanjiCell(store: $0)
                        }
                        if !vs.isLastPage && !vs.isSearching {
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
                .scrollIndicators(.hidden)
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .withBannerAD()
            .onAppear { vs.send(.onAppear) }
            .navigationTitle("한자 리스트")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: vs.binding(
                get: \.showEditModal,
                send: KanjiList.Action.showEditView)
            ) {
                IfLetStore(store.scope(
                    state: \.edit,
                    action: KanjiList.Action.edit)
                ) {
                    EditKanjiView(store: $0)
                }
            }
        }
    }
}

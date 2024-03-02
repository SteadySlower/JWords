//
//  KanjiList.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct KanjiList {
    // FIXME: move it to proper place
    static let NUMBER_OF_KANJI_IN_A_PAGE = 20
    
    struct State: Equatable {
        var kanjis: IdentifiedArrayOf<DisplayKanji.State>
        var studyKanjiSamples: StudyKanjiSamples.State?
        var isLastPage = false
        var searchKanji = SearchKanji.State()
        @PresentationState var edit: EditKanji.State?
        @PresentationState var addWriting: AddWritingKanji.State?
        
        var showStudyView: Bool {
            studyKanjiSamples != nil
        }
        
        var isSearching: Bool {
            !searchKanji.query.isEmpty
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchKanjis
        case studyKanjiSamples(StudyKanjiSamples.Action)
        case showStudyView(Bool)
        case searchKanji(SearchKanji.Action)
        case kanji(IdentifiedActionOf<DisplayKanji>)
        case edit(PresentationAction<EditKanji.Action>)
        case addWriting(PresentationAction<AddWritingKanji.Action>)
    }
    
    @Dependency(\.kanjiClient) var kanjiClient
    @Dependency(\.kanjiSetClient) var kanjiSetClient
    
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
                let idArrayOfFetched = fetched.map { DisplayKanji.State(kanji: $0) }
                state.kanjis.append(contentsOf: IdentifiedArray(uniqueElements: idArrayOfFetched))
            case .kanji(.element(_, .showSamples(let kanji))):
                let units = try! kanjiClient.kanjiUnits(kanji)
                state.studyKanjiSamples = StudyKanjiSamples.State(kanji: kanji, units: units)
            case .kanji(.element(_, .edit(let kanji))):
                state.edit = EditKanji.State(kanji)
            case .kanji(.element(_, .addToWrite(let kanji))):
                let sets = try! kanjiSetClient.fetch()
                state.addWriting = AddWritingKanji.State(kanji: kanji, kanjiSets: sets)
            case .showStudyView(let isPresent):
                if !isPresent { state.studyKanjiSamples = nil }
                return .none
            case .edit(.presented(.cancel)):
                state.edit = nil
            case .edit(.presented(.edited(let kanji))):
                state.kanjis.updateOrAppend(DisplayKanji.State(kanji: kanji))
                state.edit = nil
            case .addWriting(.presented(.added)), .addWriting(.presented(.cancel)):
                state.addWriting = nil
            case .searchKanji(.updateQuery(let query)):
                // If query is empty, fetch all kanjis
                return query.isEmpty ? .send(.fetchKanjis) : .none
            case .searchKanji(.kanjiSearched(let kanjis)):
                state.kanjis = IdentifiedArray(uniqueElements: kanjis.map { DisplayKanji.State(kanji: $0) })
            default: break
            }
            return .none
        }
        .forEach(\.kanjis, action: \.kanji) { DisplayKanji() }
        .ifLet(\.studyKanjiSamples, action: \.studyKanjiSamples) { StudyKanjiSamples() }
        .ifLet(\.$edit, action: \.edit) { EditKanji() }
        .ifLet(\.$addWriting, action: \.addWriting) { AddWritingKanji() }
        Scope(state: \.searchKanji, action: \.searchKanji) { SearchKanji() }
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
                                action: \.studyKanjiSamples)
                            ) { StudyKanjiSampleView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyView,
                                send: KanjiList.Action.showStudyView))
                { EmptyView() }
                KanjiSearchBar(
                    store: store.scope(
                        state: \.searchKanji,
                        action: \.searchKanji)
                )
                ScrollView {
                    LazyVStack {
                        ForEachStore(store.scope(
                            state: \.kanjis,
                            action: \.kanji)
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
            .sheet(store: store.scope(state: \.$edit, action: \.edit)) {
                EditKanjiView(store: $0)
            }
            .sheet(store: store.scope(state: \.$addWriting, action: \.addWriting)) {
                AddWritingKanjiView(store: $0)
            }
        }
    }
}

#Preview {
    KanjiListView(store: .init(
        initialState: KanjiList.State(
            kanjis: IdentifiedArray(
                uniqueElements: [Kanji].mock.map { DisplayKanji.State(kanji: $0) }
            )
        ),
        reducer: { KanjiList() })
    )
}

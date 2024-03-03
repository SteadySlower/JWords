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
    @ObservableState
    struct State: Equatable {
        var kanjis: IdentifiedArrayOf<DisplayKanji.State>
        var isLastPage = false
        var searchKanji = SearchKanji.State()
        
        @Presents var destination: Destination.State?
        
        var isSearching: Bool {
            !searchKanji.query.isEmpty
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case edit(EditKanji)
        case addWriting(AddWritingKanji)
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchKanjis
        case searchKanji(SearchKanji.Action)
        case kanji(IdentifiedActionOf<DisplayKanji>)
        
        case destination(PresentationAction<Destination.Action>)
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
            case .kanji(.element(_, .edit(let kanji))):
                state.destination = .edit(EditKanji.State(kanji))
            case .kanji(.element(_, .addToWrite(let kanji))):
                let sets = try! kanjiSetClient.fetch()
                state.destination = .addWriting(AddWritingKanji.State(kanji: kanji, kanjiSets: sets))
            case .destination(.presented(.edit(.edited(let kanji)))):
                state.kanjis.updateOrAppend(DisplayKanji.State(kanji: kanji))
                state.destination = nil
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
        .ifLet(\.$destination, action: \.destination)
        Scope(state: \.searchKanji, action: \.searchKanji) { SearchKanji() }
    }

}

struct KanjiListView: View {
    
    @Bindable var store: StoreOf<KanjiList>
    
    var body: some View {
        VStack {
            KanjiSearchBar(
                store: store.scope(
                    state: \.searchKanji,
                    action: \.searchKanji)
            )
            ScrollView {
                LazyVStack {
                    ForEach(
                        store.scope(state: \.kanjis, action: \.kanji),
                        id: \.state.id
                    ) { KanjiCell(store: $0) }
                    if !store.isLastPage && !store.isSearching {
                        ProgressView()
                            .foregroundColor(.gray)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    store.send(.fetchKanjis)
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
        .onAppear { store.send(.onAppear) }
        .navigationTitle("한자 리스트")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) {
            EditKanjiView(store: $0)
        }
        .sheet(item: $store.scope(state: \.destination?.addWriting, action: \.destination.addWriting)) {
            AddWritingKanjiView(store: $0)
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

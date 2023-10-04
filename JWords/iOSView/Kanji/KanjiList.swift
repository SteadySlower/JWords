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
        var studyKanjiSamples: StudyKanjiSamples.State?
        var isLastPage = false
        
        var showStudyView: Bool {
            studyKanjiSamples != nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchKanjis
        case kanjiCellTapped(Kanji)
        case studyKanjiSamples(StudyKanjiSamples.Action)
        case showStudyView(Bool)
    }
    
    @Dependency(\.kanjiClient) var kanjiClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { .fetchKanjis }
            case .fetchKanjis:
                let last = state.kanjis.last
                let fetched = try! kanjiClient.fetch(last)
                if fetched.count < KanjiList.NUMBER_OF_KANJI_IN_A_PAGE { state.isLastPage = true }
                state.kanjis.append(contentsOf: fetched)
                return .none
            case .kanjiCellTapped(let kanji):
                let units = try! kanjiClient.kanjiUnits(kanji)
                state.studyKanjiSamples = StudyKanjiSamples.State(kanji: kanji, units: units)
                return .none
            case .showStudyView(let isPresent):
                if !isPresent {
                    state.studyKanjiSamples = nil
                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.studyKanjiSamples, action: /Action.studyKanjiSamples) {
            StudyKanjiSamples()
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
                                state: \.studyKanjiSamples,
                                action: KanjiList.Action.studyKanjiSamples)
                            ) { StudyKanjiSampleView(store: $0) },
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
                        .padding(.horizontal, 20)
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
                    .padding(.top, 10)
                }
            }
            .withBannerAD()
            .onAppear { vs.send(.onAppear) }
            .navigationTitle("한자 리스트")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

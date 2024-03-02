//
//  MainTabView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

enum Tab {
    case today, home, kanji, kanjiWriting, ocr
}

@Reducer
struct MainTab {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .today
        var todayList: TodayList.State = .init()
        var homeList: HomeList.State = .init()
        var kanjiList: KanjiList.State = .init(kanjis: [])
        var kanjiSetList: KanjiSetList.State = .init(sets: [])
        var ocr: AddUnitWithOCR.State = .init()
    }
    
    enum Action: Equatable {
        case tabChanged(Tab)
        case todayList(TodayList.Action)
        case homeList(HomeList.Action)
        case kanjiList(KanjiList.Action)
        case kanjiSetList(KanjiSetList.Action)
        case ocr(AddUnitWithOCR.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabChanged(let tab):
                state.selectedTab = tab
            default: break
            }
            return .none
        }
        Scope(state: \.todayList, action: \.todayList) { TodayList() }
        Scope(state: \.homeList, action: \.homeList) { HomeList() }
        Scope(state: \.kanjiList, action: \.kanjiList) { KanjiList() }
        Scope(state: \.kanjiSetList, action: \.kanjiSetList) { KanjiSetList() }
        Scope(state: \.ocr, action: \.ocr) { AddUnitWithOCR() }
    }
    
}

struct MainTabView: View {
    
    @Bindable var store: StoreOf<MainTab>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabChanged)) {
            NavigationStack {
                TodayView(store: store.scope(
                    state: \.todayList,
                    action: \.todayList)
                )
            }
            .tabItem { Label("오늘 단어장", systemImage: "calendar") }
            .tag(Tab.today)
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
            NavigationStack {
                HomeView(store: store.scope(
                    state: \.homeList,
                    action: \.homeList)
                )
            }
            .tabItem { Label("모든 단어장", systemImage: "books.vertical") }
            .tag(Tab.home)
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
            NavigationStack {
                KanjiListView(store: store.scope(
                    state: \.kanjiList,
                    action: \.kanjiList)
                )
            }
            .tabItem {
            #if os(iOS)
            Label {
                Text("한자 리스트")
            } icon: {
                Image(uiImage:
                        ImageRenderer(content: Text("漢").font(.title)).uiImage ?? UIImage()
                )
            }
            #endif
            }
            .tag(Tab.kanji)
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationStack {
                    KanjiSetListView(store: store.scope(
                        state: \.kanjiSetList,
                        action: \.kanjiSetList)
                    )
                }
                .tabItem { Label("한자 쓰기", systemImage: "applepencil.and.scribble") }
                .tag(Tab.kanjiWriting)
                #if os(iOS)
                .navigationViewStyle(.stack)
                #endif
            }
            NavigationStack {
                OCRAddUnitView(store: store.scope(
                    state: \.ocr,
                    action: \.ocr)
                )
            }
            .tabItem { Label("단어 스캐너", systemImage: "scanner") }
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
            .tag(Tab.ocr)
        }
        .tint(.black)
        .onAppear { setTabBar() }
    }
    
    private func setTabBar() {
        // navigation 들어갔다가 나올 때 탭바 투명 방지
        #if os(iOS)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        #endif
    }
}

struct iOSAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(
            store: Store(
                initialState: MainTab.State(),
                reducer: { MainTab()._printChanges() }
            )
        )
    }
}

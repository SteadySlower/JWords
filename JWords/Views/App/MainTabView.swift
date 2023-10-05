//
//  MainTabView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

enum Tab {
    case today, home, kanji, ocr
}

struct MainTab: ReducerProtocol {
    
    struct State: Equatable {
        var selectedTab: Tab = .today
        var todayList: TodayList.State? = TodayList.State()
        var homeList: HomeList.State?
        var kanjiList: KanjiList.State?
        var ocr: AddUnitWithOCR.State?
        
        mutating func clearList() {
            todayList = nil
            homeList = nil
            kanjiList = nil
            ocr = nil
        }
    }
    
    enum Action: Equatable {
        case tabChanged(Tab)
        case todayList(TodayList.Action)
        case homeList(HomeList.Action)
        case kanjiList(KanjiList.Action)
        case ocr(AddUnitWithOCR.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabChanged(let tab):
                state.clearList()
                state.selectedTab = tab
                switch tab {
                case .today:
                    state.todayList = TodayList.State()
                case .home:
                    state.homeList = HomeList.State()
                case .kanji:
                    state.kanjiList = KanjiList.State()
                case .ocr:
                    state.ocr = AddUnitWithOCR.State()
                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.todayList, action: /Action.todayList) {
            TodayList()
        }
        .ifLet(\.homeList, action: /Action.homeList) {
            HomeList()
        }
        .ifLet(\.kanjiList, action: /Action.kanjiList) {
            KanjiList()
        }
        .ifLet(\.ocr, action: /Action.ocr) {
            AddUnitWithOCR()
        }
    }
    
}

struct MainTabView: View {
    
    let store: StoreOf<MainTab>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            TabView(selection:
                vs.binding(get: \.selectedTab, send: MainTab.Action.tabChanged)
            ) {
                NavigationView {
                    IfLetStore(store.scope(
                        state: \.todayList,
                        action: MainTab.Action.todayList)
                    ) {
                        TodayView(store: $0)
                    }
                }
                .tabItem { Label("오늘 단어장", systemImage: "calendar") }
                .tag(Tab.today)
                #if os(iOS)
                .navigationViewStyle(.stack)
                #endif
                NavigationView {
                    IfLetStore(store.scope(
                        state: \.homeList,
                        action: MainTab.Action.homeList)
                    ) {
                        HomeView(store: $0)
                    }
                }
                .tabItem { Label("모든 단어장", systemImage: "books.vertical") }
                .tag(Tab.home)
                #if os(iOS)
                .navigationViewStyle(.stack)
                #endif
                NavigationView {
                    IfLetStore(store.scope(
                        state: \.kanjiList,
                        action: MainTab.Action.kanjiList)
                    ) {
                        KanjiListView(store: $0)
                    }
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
                NavigationView {
                    IfLetStore(store.scope(
                        state: \.ocr,
                        action: MainTab.Action.ocr)
                    ) {
                        OCRAddUnitView(store: $0)
                    }
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
                reducer: MainTab()._printChanges()
            )
        )
    }
}

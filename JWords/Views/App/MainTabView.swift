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
    }
    
    enum Action: Equatable {
        case setTab(Tab)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setTab(let tab):
                state.selectedTab = tab
            }
            return .none
        }
    }
    
}

struct MainTabView: View {
    
    @Bindable var store: StoreOf<MainTab>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.setTab)) {
            TodayCoordinatorView(
                store: .init(initialState: .init(),
                reducer: { TodayCoordinator() })
            )
            .tabItem { Label("오늘 단어장", systemImage: "calendar") }
            .tag(Tab.today)
            SetCoordinatorView(store: .init(initialState: .init(), reducer: { SetCoordinator() }))
            .tabItem { Label("모든 단어장", systemImage: "books.vertical") }
            .tag(Tab.home)
            KanjiCoordinatorView(store: .init(initialState: .init(), reducer: { KanjiCoordinator() }))
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
            if UIDevice.current.userInterfaceIdiom == .pad {
                WritingCoordinatorView(store: .init(initialState: .init(), reducer: { WritingCoordinator() }))
                .tabItem { Label("한자 쓰기", systemImage: "applepencil.and.scribble") }
                .tag(Tab.kanjiWriting)
            }
            ScannerCoordinatorView(store: .init(initialState: .init(), reducer: { ScannerCoordinator() }))
            .tabItem { Label("단어 스캐너", systemImage: "scanner") }
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

//
//  iOSAppView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

enum Tab {
    case today, home, kanji, test
}

struct iOSApp: ReducerProtocol {
    
    struct State: Equatable {
        var selectedTab: Tab = .today
        var todayList: TodayList.State? = TodayList.State()
        var homeList: HomeList.State?
        var kanjiList: KanjiList.State?
        
        mutating func clearList() {
            todayList = nil
            homeList = nil
        }
    }
    
    enum Action: Equatable {
        case tabChanged(Tab)
        case todayList(action: TodayList.Action)
        case homeList(action: HomeList.Action)
        case kanjiList(action: KanjiList.Action)
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    
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
                // TODO: remove when coredata conversion is finished
                default:
                    break
                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.todayList, action: /Action.todayList(action:)) {
            TodayList()
        }
        .ifLet(\.homeList, action: /Action.homeList(action:)) {
            HomeList()
        }
        .ifLet(\.kanjiList, action: /Action.kanjiList(action:)) {
            KanjiList()
        }
    }
    
}

struct iOSAppView: View {
    
    let store: StoreOf<iOSApp>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            TabView(selection:
                vs.binding(get: \.selectedTab, send: iOSApp.Action.tabChanged)
            ) {
                NavigationView {
                    IfLetStore(self.store.scope(
                        state: \.todayList,
                        action: iOSApp.Action.todayList(action:))
                    ) {
                        TodayView(store: $0)
                    }
                }
                .tabItem { Image(systemName: "calendar") }
                .tag(Tab.today)
                #if os(iOS)
                .navigationViewStyle(.stack)
                #endif
                NavigationView {
                    IfLetStore(self.store.scope(
                        state: \.homeList,
                        action: iOSApp.Action.homeList(action:))
                    ) {
                        HomeView(store: $0)
                    }
                }
                .tabItem { Image(systemName: "house") }
                .tag(Tab.home)
                #if os(iOS)
                .navigationViewStyle(.stack)
                #endif
                NavigationView {
                    IfLetStore(self.store.scope(
                        state: \.kanjiList,
                        action: iOSApp.Action.kanjiList(action:))
                    ) {
                        KanjiListView(store: $0)
                    }
                }
                .tabItem {
                    Image(uiImage:
                            ImageRenderer(content: Text("漢").font(.title)).uiImage ?? UIImage()
                    )
                }
                .tag(Tab.kanji)
                #if os(iOS)
                .navigationViewStyle(.stack)
                #endif
                NavigationView {
                    CoreDataTestView()
                }
                .tabItem { Image(systemName: "pencil") }
                .tag(Tab.test)
            }
        }
    }
}

struct iOSAppView_Previews: PreviewProvider {
    static var previews: some View {
        iOSAppView(
            store: Store(
                initialState: iOSApp.State(),
                reducer: iOSApp()._printChanges()
            )
        )
    }
}

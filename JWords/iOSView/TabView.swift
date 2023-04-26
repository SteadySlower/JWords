//
//  TabView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

struct MainTabView: View {
    @State private var showModal = false
    private let dependency: ServiceManager
    
    init(_ dependency: ServiceManager) {
        self.dependency = dependency
    }
    
    var body: some View {
        TabView {
            NavigationView {
                TodayView(
                    store: Store(
                        initialState: TodayList.State(),
                        reducer: TodayList()._printChanges()
                    )
                )
            }
            .tabItem { Image(systemName: "calendar") }
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
            NavigationView {
                HomeView(dependency)
                    .navigationTitle("단어장 목록")
            }
            .tabItem { Image(systemName: "house") }
            #if os(iOS)
            .navigationViewStyle(.stack)
            #endif
        }
    }
}

//
//  TabView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct MainTabView: View {
    @State private var showModal = false
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    
    var body: some View {
        TabView {
            NavigationView {
                TodayView(dependency)
                    .navigationTitle("오늘의 단어")
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

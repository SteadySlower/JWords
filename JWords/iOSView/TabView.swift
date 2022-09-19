//
//  TabView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedIndex: Int = 0
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            NavigationView { TodayView(dependency) }
                .onTapGesture { selectedIndex = 0 }
                .tabItem { Image(systemName: "calendar") }
                .tag(0)
            NavigationView { HomeView(dependency)  }
                .onTapGesture { selectedIndex = 1 }
                .tabItem { Image(systemName: "house") }
                .tag(1)
        }
    }
}

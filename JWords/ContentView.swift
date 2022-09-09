//
//  ContentView.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI

struct ContentView: View {
    
    private let dependency: Dependency
    
    init() {
        self.dependency = DependencyImpl()
    }
    
    var body: some View {
        Group {
            #if os(iOS)
            HomeView(dependency)
            #elseif os(macOS)
            MacHomeView(dependency)
            #endif
        }
    }
}

//
//  ContentView.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI

struct ContentView: View {
    
    private let dependency: ServiceManager
    
    init(_ dependency: ServiceManager) {
        self.dependency = dependency
    }
    
    var body: some View {
        Group {
            #if os(iOS)
            MainTabView(dependency)
            #elseif os(macOS)
            MacHomeView(dependency)
            #endif
        }
    }
}

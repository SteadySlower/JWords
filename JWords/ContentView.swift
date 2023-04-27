//
//  ContentView.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    
    private let dependency: ServiceManager
    
    init(_ dependency: ServiceManager) {
        self.dependency = dependency
    }
    
    var body: some View {
        Group {
            #if os(iOS)
            iOSAppView(
                store: Store(
                    initialState: iOSApp.State(),
                    reducer: iOSApp()._printChanges()
                )
            )
            #elseif os(macOS)
            MacHomeView(dependency)
            #endif
        }
    }
}

//
//  ContentView.swift
//  JWords
//
//  Created by JW Moon on 2022/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        HomeView()
        #elseif os(macOS)
        MacHomeView()
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

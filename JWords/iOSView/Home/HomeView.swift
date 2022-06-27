//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(0..<20) { _ in
                        HomeCell()
                    }
                }
            }
        }
        .navigationTitle("단어장 목록")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

//
//  MacHomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
#if os(macOS)
struct MacHomeView: View {
    
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                BookListNavigationView(dependency)
                WordAddNavigationView(dependency)
            }
        }
        .navigationViewStyle(.automatic)
    }
}

private struct BookListNavigationView: View {
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    
    var body: some View {
        NavigationLink {
            MacAddBookView(dependency)
        } label: {
            Text("add book")
        }
    }
}

private struct WordAddNavigationView: View {

    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    var body: some View {
        NavigationLink {
            MacAddWordView(dependency)
        } label: {
            Text("add word")
        }
    }
}

#elseif os(iOS)
struct MacHomeView: View {
    var body: some View {
        EmptyView()
    }
}
#endif

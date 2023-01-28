//
//  MacHomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct MacHomeView: View {
    
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.dependency = dependency
    }
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                addBookView
                wordAddView
            }
        }
        .navigationViewStyle(.automatic)
    }
}

// MARK: SubViews

extension MacHomeView {
    
    private var addBookView: some View {
        NavigationLink {
            MacAddBookView(dependency)
        } label: {
            Text("add book")
        }
    }
    
    private var wordAddView: some View {
        NavigationLink {
            MacAddWordView(dependency)
        } label: {
            Text("add word")
        }
    }
    
}

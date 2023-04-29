//
//  MacHomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture

struct MacHomeView: View {
    
    private let dependency: ServiceManager
    
    init(_ dependency: ServiceManager) {
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
            MacAddBookView(
                store: Store(
                    initialState: AddBook.State(),
                    reducer: AddBook()._printChanges()
                )
            )
        } label: {
            Text("add book")
        }
    }
    
    private var wordAddView: some View {
        NavigationLink {
            MacAddWordView(
                store: Store(
                    initialState: AddWord.State(),
                    reducer: AddWord()._printChanges()
                )
            )
        } label: {
            Text("add word")
        }
    }
    
}

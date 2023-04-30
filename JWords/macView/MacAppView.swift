//
//  MacAppView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture

struct MacApp: ReducerProtocol {
    
    struct State: Equatable {
        var addBook = AddBook.State()
        var addWord = AddWord.State()
    }
    
    enum Action: Equatable {
        case addBook(action: AddBook.Action)
        case addWord(action: AddWord.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        Scope(state: \.addBook, action: /Action.addBook(action:)) {
            AddBook()
        }
        Scope(state: \.addWord, action: /Action.addWord(action:)) {
            AddWord()
        }
    }
    
}

struct MacAppView: View {
    
    let store: StoreOf<MacApp>
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                NavigationLink {
                    MacAddBookView(store: store.scope(
                        state: \.addBook,
                        action: MacApp.Action.addBook(action:))
                    )
                } label: {
                    Text("add book")
                }
                NavigationLink {
                    MacAddWordView(store: store.scope(
                        state: \.addWord,
                        action: MacApp.Action.addWord(action:))
                    )
                } label: {
                    Text("add word")
                }
                NavigationLink {
                    HuriganaTestView()
                } label: {
                    Text("hurigana test")
                }
            }
        }
        .navigationViewStyle(.automatic)
    }
}

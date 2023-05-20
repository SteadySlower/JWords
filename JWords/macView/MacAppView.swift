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
        var wordList = MacWordList.State()
    }
    
    enum Action: Equatable {
        case addBook(action: AddBook.Action)
        case addWord(action: AddWord.Action)
        case wordList(action: MacWordList.Action)
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
        Scope(state: \.wordList, action: /Action.wordList(action:)) {
            MacWordList()
        }
    }
    
}

struct MacAppView: View {
    
    let store: StoreOf<MacApp>
    
    var body: some View {
        TabView {
            MacAddBookView(store: store.scope(
                state: \.addBook,
                action: MacApp.Action.addBook(action:))
            )
            .tabItem { Text("단어장 추가") }
            MacAddWordView(store: store.scope(
                state: \.addWord,
                action: MacApp.Action.addWord(action:))
            )
            .tabItem { Text("단어 추가") }
            MacStudyView(store: store.scope(
                state: \.wordList,
                action: MacApp.Action.wordList(action:))
            )
            .tabItem { Text("단어 공부") }
        }
        .navigationViewStyle(.automatic)
    }
}

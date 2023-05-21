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
        var conversionList = ConversionList.State()
    }
    
    enum Action: Equatable {
        case addBook(action: AddBook.Action)
        case addWord(action: AddWord.Action)
        case conversionList(action: ConversionList.Action)
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
        Scope(state: \.conversionList, action: /Action.conversionList(action:)) {
            ConversionList()
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
            ConversionView(store: store.scope(
                state: \.conversionList,
                action: MacApp.Action.conversionList(action:))
            )
            .tabItem { Text("데이터 이동") }
        }
        .navigationViewStyle(.automatic)
    }
}

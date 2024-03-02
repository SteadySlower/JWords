//
//  MacAppView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MacApp {
    
    struct State: Equatable {
        var kanjiList = KanjiList.State(kanjis: [])
        var ocr = AddUnitWithOCR.State()
    }
    
    enum Action: Equatable {
        case kanjiList(KanjiList.Action)
        case ocr(AddUnitWithOCR.Action)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
        Scope(state: \.kanjiList, action: \.kanjiList) { KanjiList() }
        Scope(state: \.ocr, action: \.ocr) { AddUnitWithOCR() }
    }
    
}

struct MacAppView: View {
    
    let store: StoreOf<MacApp>
    
    var body: some View {
        TabView {
            KanjiListView(store: store.scope(
                state: \.kanjiList,
                action: \.kanjiList)
            )
            .tabItem { Text("한자 리스트") }
            OCRAddUnitView(store: store.scope(
                state: \.ocr,
                action: \.ocr)
            )
            .tabItem { Text("OCR") }
        }
    }
}

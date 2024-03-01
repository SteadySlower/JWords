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
        case kanjiList(action: KanjiList.Action)
        case ocr(action: AddUnitWithOCR.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        Scope(state: \.kanjiList, action: /Action.kanjiList(action:)) {
            KanjiList()
        }
        Scope(state: \.ocr, action: /Action.ocr(action:)) {
            AddUnitWithOCR()
        }
    }
    
}

struct MacAppView: View {
    
    let store: StoreOf<MacApp>
    
    var body: some View {
        TabView {
            KanjiListView(store: store.scope(
                state: \.kanjiList,
                action: MacApp.Action.kanjiList(action:))
            )
            .tabItem { Text("한자 리스트") }
            OCRAddUnitView(store: store.scope(
                state: \.ocr,
                action: MacApp.Action.ocr(action:))
            )
            .tabItem { Text("OCR") }
        }
    }
}

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
        var addSet = InputBook.State()
        var addUnit = SelectSetAddUnit.State()
        var kanjiList = KanjiList.State()
        var ocr = AddUnitWithOCR.State()
    }
    
    enum Action: Equatable {
        case addSet(action: InputBook.Action)
        case addUnit(action: SelectSetAddUnit.Action)
        case kanjiList(action: KanjiList.Action)
        case ocr(action: AddUnitWithOCR.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        Scope(state: \.addSet, action: /Action.addSet(action:)) {
            InputBook()
        }
        Scope(state: \.addUnit, action: /Action.addUnit(action:)) {
            SelectSetAddUnit()
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
            MacSetAddView(store: store.scope(
                state: \.addSet,
                action: MacApp.Action.addSet(action:))
            )
            .tabItem { Text("단어장 추가 (신)") }
            MacAddUnitView(store: store.scope(
                state: \.addUnit,
                action: MacApp.Action.addUnit(action:))
            )
            .tabItem { Text("단어 추가 (신)") }
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

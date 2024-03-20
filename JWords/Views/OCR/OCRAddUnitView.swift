//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AddUnitWithOCR {
    @ObservableState
    struct State: Equatable {
        var ocr = OCR.State()
        var selectSet = SelectStudySet.State()
        var addUnit = AddUnit.State()
    }
    
    enum Action: Equatable {
        case ocr(OCR.Action)
        case selectSet(SelectStudySet.Action)
        case addUnit(AddUnit.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .ocr(.koreanOCR(let meaning)):
                state.addUnit.inputUnit.meaningInput.text = meaning
            case .ocr(.japaneseOCR(let kanji)):
                state.addUnit.inputUnit.kanjiInput.isEditing = true
                state.addUnit.inputUnit.kanjiInput.hurigana = .init(hurigana: "")
                state.addUnit.inputUnit.kanjiInput.text = kanji
            case .selectSet(.idUpdated(let set)):
                state.addUnit.set = set
            case .addUnit(.added):
                state.addUnit.clearInput()
                state.selectSet.onUnitAdded()
            default: break
            }
            return .none
        }
        Scope(state: \.ocr, action: \.ocr) { OCR() }
        Scope(state: \.selectSet, action: \.selectSet) { SelectStudySet() }
        Scope(state: \.addUnit, action: \.addUnit) { AddUnit() }
    }
}

struct OCRAddUnitView: View {
    
    let store: StoreOf<AddUnitWithOCR>
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 35) {
                OCRView(store: store.scope(
                    state: \.ocr,
                    action: \.ocr)
                )
                StudySetPicker(store: store.scope(
                    state: \.selectSet,
                    action: \.selectSet),
                    pickerName: ""
                )
                AddUnitView(store: store.scope(
                    state: \.addUnit,
                    action: \.addUnit)
                )
            }
            .padding(.vertical, 10)
            .dismissKeyboardWhenBackgroundTapped()
        }
        .withBannerAD()
        .padding(.horizontal, 10)
        .navigationTitle("단어 스캐너")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}


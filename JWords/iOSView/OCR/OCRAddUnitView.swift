//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import SwiftUI
import ComposableArchitecture

struct AddUnitWithOCR: ReducerProtocol {
    struct State: Equatable {
        var ocr = OCR.State()
        var selectSet = SelectStudySet.State(pickerName: "")
        var addUnit = AddUnit.State()
    }
    
    enum Action: Equatable {
        case ocr(OCR.Action)
        case selectSet(SelectStudySet.Action)
        case addUnit(AddUnit.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .ocr(let action):
                switch action {
                case .koreanOCR(let meaning):
                    state.addUnit.inputUnit.meaningInput.text = meaning
                    return .none
                case .japaneseOCR(let kanji):
                    state.addUnit.inputUnit.kanjiInput.isEditing = true
                    state.addUnit.inputUnit.kanjiInput.hurigana = .init(hurigana: "")
                    state.addUnit.inputUnit.kanjiInput.text = kanji
                    return .none
                default: return .none
                }
            case .selectSet(let action):
                switch action {
                case .idUpdated:
                    if let set = state.selectSet.selectedSet {
                        state.addUnit.set = set
                    } else {
                        state.addUnit.set = nil
                    }
                    return .none
                default: return .none
                }
            case .addUnit(let action):
                switch action {
                case .added:
                    state.addUnit.clearInput()
                    state.selectSet.onUnitAdded()
                    return .none
                default: return .none
                }
            }
        }
        Scope(state: \.ocr, action: /Action.ocr) {
            OCR()
        }
        Scope(state: \.selectSet, action: /Action.selectSet) {
            SelectStudySet()
        }
        Scope(state: \.addUnit, action: /Action.addUnit) {
            AddUnit()
        }
    }
}

struct OCRAddUnitView: View {
    
    let store: StoreOf<AddUnitWithOCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {
                    OCRView(store: store.scope(
                        state: \.ocr,
                        action: AddUnitWithOCR.Action.ocr)
                    )
                    StudySetPicker(store: store.scope(
                        state: \.selectSet,
                        action: AddUnitWithOCR.Action.selectSet)
                    )
                    AddUnitView(store: store.scope(
                        state: \.addUnit,
                        action: AddUnitWithOCR.Action.addUnit)
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
}


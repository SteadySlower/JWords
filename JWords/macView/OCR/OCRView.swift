//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct OCR: ReducerProtocol {
    
    struct State: Equatable {
        var getImage = GetImageForOCR.State()
        var ocr: GetWordsFromOCR.State?
    }
    
    enum Action: Equatable {
        case getImage(GetImageForOCR.Action)
        case ocr(GetWordsFromOCR.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        .ifLet(\.ocr, action: /Action.ocr) {
            GetWordsFromOCR()
        }
        Scope(state: \.getImage, action: /Action.getImage) {
            GetImageForOCR()
        }
    }
    
}

struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            if vs.ocr == nil {
                GetImageForOCRView(store: store.scope(
                    state: \.getImage,
                    action: OCR.Action.getImage)
                )
            } else {
                IfLetStore(store.scope(
                    state: \.ocr,
                    action: OCR.Action.ocr)
                ) {
                    OCRResultView(store: $0)
                }
            }
        }
    }
}

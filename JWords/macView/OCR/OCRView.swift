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
    }
    
}

struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
}

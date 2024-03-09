//
//  ScannerCoordinatorView.swift
//  JWords
//
//  Created by JW Moon on 3/2/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ScannerCoordinator {
    @ObservableState
    struct State: Equatable {
        var ocr: AddUnitWithOCR.State = .init()
    }
    
    enum Action {
        case ocr(AddUnitWithOCR.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.ocr, action: \.ocr) { AddUnitWithOCR() }
    }
}

struct ScannerCoordinatorView: View {
    
    let store: StoreOf<ScannerCoordinator>
    
    var body: some View {
        NavigationStack {
            OCRAddUnitView(store: store.scope(
                state: \.ocr,
                action: \.ocr)
            )
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        #endif
    }
}


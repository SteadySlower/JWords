//
//  KanjiCanvas.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct DrawWithPencil {
    @ObservableState
    struct State: Equatable {
        var didDraw: Bool = false
    }
    
    enum Action: Equatable {
        case resetCanvas
        case setDidDraw(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .resetCanvas:
                state.didDraw = false
            case .setDidDraw(let bool):
                state.didDraw = bool
            }
            return .none
        }
    }
}

struct KanjiCanvas: View {
    
    @Bindable var store: StoreOf<DrawWithPencil>
    
    var body: some View {
        VStack {
            CanvasView(didDraw: $store.didDraw.sending(\.setDidDraw))
            .border(.black)
            HStack {
                Spacer()
                Button(action: {
                    store.send(.resetCanvas)
                }, label: {
                    Image(systemName: "eraser")
                        .resizable()
                        .frame(width: 50, height: 50)
                })
            }
            .padding([.trailing, .bottom], 20)
        }
    }
}

#Preview {
    KanjiCanvas(store: .init(
        initialState: DrawWithPencil.State(),
        reducer: { DrawWithPencil() })
    )
}

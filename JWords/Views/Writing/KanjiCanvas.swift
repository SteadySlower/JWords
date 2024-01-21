//
//  KanjiCanvas.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import PencilKit
import ComposableArchitecture

struct DrawWithPencil: Reducer {
    
    struct State: Equatable {
        var canvas: PKCanvasView
    }
    
    enum Action: Equatable {
        case toggleShowAnswer
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
    
}

struct KanjiCanvas: View {
    @State private var didDraw: Bool = false
    
    var body: some View {
        ZStack {
            CanvasView(didDraw: $didDraw)
            resetButton
                .padding([.trailing, .bottom], 20)
        }
    }
}

extension KanjiCanvas {
    var resetButton: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    didDraw = false
                }, label: {
                    Image(systemName: "eraser")
                        .resizable()
                        .frame(width: 50, height: 50)
                })
            }
        }
    }
}

#Preview {
    KanjiCanvas()
}

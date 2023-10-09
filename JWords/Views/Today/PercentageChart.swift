//
//  PercentageChart.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import ComposableArchitecture
import SwiftUI

struct PieChartReducer: Reducer {
    struct State: Equatable {
        private(set) var _percentage: Float = 0.0
        var displayPercentage: Float = 0.0
        
        mutating func clear() {
            _percentage = 0.0
            displayPercentage = 0.0
        }
        
        mutating func updatePercentage(_ percentage: Float) {
            displayPercentage = 0.0
            _percentage = percentage
        }
    }
    
    enum Action: Equatable {
        case startAnimation
        case addToDisplayPercentage(Float)
        case clearState
    }
    
    @Dependency(\.continuousClock) var clock
    enum CancelID { case timer }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startAnimation:
                let percentage = state._percentage
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(0.005)) {
                        await send(.addToDisplayPercentage(percentage / 200))
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
            case .addToDisplayPercentage(let percentage):
                state.displayPercentage += percentage
                if state.displayPercentage > state._percentage {
                    state.displayPercentage = state._percentage
                    return .cancel(id: CancelID.timer)
                }
                return .none
            case .clearState:
                state.clear()
                return .none
            }
        }
    }
}

struct PercentageChart: View {
    
    let store: StoreOf<PieChartReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                Circle()
                    .stroke(Color.blue, lineWidth: 10)
                Circle()
                    .trim(from: 0.0, to: CGFloat(vs.displayPercentage))
                    .stroke(Color.red, lineWidth: 10)
                    .rotationEffect(.degrees(-90))
                Text("\(String(format: "%.1f", vs.displayPercentage * 100))%")
                    .font(.body)
                    .fixedSize()
            }
            .padding(5)
            .onAppear { vs.send(.startAnimation) }
            .onDisappear { vs.send(.clearState) }
        }
    }
}

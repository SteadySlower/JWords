//
//  PercentageChart.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct PieChartReducer {
    @ObservableState
    struct State: Equatable {
        var percentage: Float = 0.0
    }
    
    enum Action: Equatable {}
    
    var body: some Reducer<State, Action> { EmptyReducer() }
}

struct PercentageChart: View {
    
    let store: StoreOf<PieChartReducer>
    @State var percentage: CGFloat = 0
    @State var timer: Timer?
    @State var counter: Int = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue, lineWidth: 10)
            Circle()
                .trim(from: 0.0, to: percentage)
                .stroke(Color.red, lineWidth: 10)
                .rotationEffect(.degrees(-90))
            Text("\(String(format: "%.1f", percentage * 100))%")
                .font(.body)
                .fixedSize()
        }
        .padding(5)
        .onAppear { startAnimation(CGFloat(store.percentage)) }
        .onDisappear { percentage = 0.0 }
    }
    
    private func startAnimation(_ percentage: CGFloat) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
            
            self.percentage += percentage / 1000
            
            if self.percentage >= percentage {
                self.percentage = percentage
                stopAnimation()
            }
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

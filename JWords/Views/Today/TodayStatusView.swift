//
//  TodayStatusView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import ComposableArchitecture
import SwiftUI

struct TodayStatus: Reducer {
    struct State: Equatable {
        private(set) var setCount: Int
        private(set) var allUnitCount: Int
        private(set) var toStudyUnitCount: Int
        var pieChart = PieChartReducer.State()
        
        var isEmpty: Bool {
            return setCount == 0
        }
        
        mutating func clear() {
            setCount = 0
            allUnitCount = 0
            toStudyUnitCount = 0
        }
        
        mutating func update(setCount: Int, allUnitCount: Int, toStudyUnitCount: Int) {
            self.setCount = setCount
            self.allUnitCount = allUnitCount
            self.toStudyUnitCount = toStudyUnitCount
            let percentage = allUnitCount != 0 ? Float(toStudyUnitCount) / Float(allUnitCount) : 0.0
            pieChart.updatePercentage(percentage)
        }
    }
    
    enum Action: Equatable {
        case onTapped
        case pieChart(PieChartReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        Scope(
            state: \.pieChart,
            action: /Action.pieChart,
            child: { PieChartReducer() }
        )
    }
}

struct TodayStatusView: View {
    
    let store: StoreOf<TodayStatus>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            Button {
                vs.send(.onTapped)
            } label: {
                if vs.setCount <= 0 {
                    VStack(spacing: 10) {
                        Text("오늘 학습할 단어장이 아직 없습니다📚")
                            .font(.system(size: 30))
                            .lineLimit(1)
                        Button {
                            vs.send(.onTapped)
                        } label: {
                            Text("📚 자동으로 추가하기")
                                .font(.system(size: 30))
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(.black)
                    .padding(8)
                    .minimumScaleFactor(0.5)
                    .defaultRectangleBackground()
                } else {
                    HStack {
                        PercentageChart(store: store.scope(
                            state: \.pieChart,
                            action: TodayStatus.Action.pieChart)
                        )
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("단어장 \(vs.setCount)권의\n모든 단어 \(vs.allUnitCount)개 중에")
                                .font(.system(size: 15))
                                .multilineTextAlignment(.trailing)
                            Text("틀린 단어 \(vs.toStudyUnitCount)개")
                                .font(.system(size: 30))
                                .multilineTextAlignment(.trailing)
                        }
                        .minimumScaleFactor(0.5)
                    }
                    .foregroundColor(.black)
                    .padding(8)
                    .defaultRectangleBackground()
                }
            }
        }
    }
}

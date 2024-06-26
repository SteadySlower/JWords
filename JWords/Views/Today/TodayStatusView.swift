//
//  TodayStatusView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import ComposableArchitecture
import SwiftUI
import Model
import CommonUI

@Reducer
struct TodayStatus {
    @ObservableState
    struct State: Equatable {
        private(set) var studySets = [StudySet]()
        private(set) var allUnits = [StudyUnit]()
        private(set) var toStudyUnits = [StudyUnit]()
        var pieChart = PieChartReducer.State()
        
        var isEmpty: Bool {
            return studySets.count == 0
        }
        
        mutating func clear() {
            studySets = []
            allUnits = []
            toStudyUnits = []
        }
        
        mutating func update(studySets: [StudySet], allUnits: [StudyUnit], toStudyUnits: [StudyUnit]) {
            self.studySets = studySets
            self.allUnits = allUnits
            self.toStudyUnits = toStudyUnits
            let percentage = allUnits.count != 0 ? Float(toStudyUnits.count) / Float(allUnits.count) : 0.0
            pieChart.percentage = percentage
        }
    }
    
    enum Action: Equatable {
        case onTapped
        case pieChart(PieChartReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
        Scope(state: \.pieChart, action: \.pieChart) { PieChartReducer() }
    }
}

struct TodayStatusView: View {
    
    let store: StoreOf<TodayStatus>
    
    var body: some View {
        Button {
            store.send(.onTapped)
        } label: {
            if store.isEmpty {
                VStack(spacing: 10) {
                    Text("오늘 학습할 단어장이 아직 없습니다📚")
                        .font(.system(size: 30))
                        .lineLimit(1)
                    Button {
                        store.send(.onTapped)
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
                        action: \.pieChart)
                    )
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("단어장 \(store.studySets.count)권의\n모든 단어 \(store.allUnits.count)개 중에")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.trailing)
                        Text("틀린 단어 \(store.toStudyUnits.count)개")
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

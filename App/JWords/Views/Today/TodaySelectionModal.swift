//
//  TodaySelectionModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import Combine
import ComposableArchitecture
import Model
import CommonUI
import tcaAPI

enum Schedule: Equatable {
    case none, study, review
}

@Reducer
struct TodaySelection {
    @ObservableState
    struct State: Equatable {
        var sets = [StudySet]()
        var schedules: [StudySet:Schedule]
        
        init(todaySets: [StudySet], reviewSets: [StudySet]) {
            var schedules = [StudySet:Schedule]()
            for set in todaySets {
                schedules[set] = .study
            }
            for set in reviewSets {
                schedules[set] = .review
            }
            self.schedules = schedules
        }
        
        mutating func toggleStudy(_ set: StudySet) {
            if schedules[set, default: .none] == .study {
                schedules[set, default: .none] = .none
            } else {
                schedules[set, default: .none] = .study
            }
        }
        
        mutating func toggleReview(_ set: StudySet) {
            if schedules[set, default: .none] == .review {
                schedules[set, default: .none] = .none
            } else {
                schedules[set, default: .none] = .review
            }
        }
        
        var studySets: [StudySet] {
            schedules.keys.filter { schedules[$0, default: .none] == .study }
        }
        
        var reviewSets: [StudySet] {
            schedules.keys.filter { schedules[$0, default: .none] == .review }
        }
        
    }
    
    @Dependency(StudySetClient.self) var setClient
    
    enum Action: Equatable {        
        case fetchSets
        case toggleStudy(StudySet)
        case toggleReview(StudySet)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                let sets = try! setClient.fetch(false)
                state.sets = sortSetsBySchedule(sets, schedule: state.schedules)
            case let .toggleStudy(set):
                state.toggleStudy(set)
            case let .toggleReview(set):
                state.toggleReview(set)
            }
            return .none
        }
    }
    
    private func sortSetsBySchedule(_ sets: [StudySet], schedule: [StudySet:Schedule]) -> [StudySet] {
        return sets.sorted(by: { set1, set2 in
            if schedule[set1, default: .none] != .none
                && schedule[set2, default: .none] == .none {
                return true
            } else {
                return false
            }
        })
    }

}

struct TodaySelectionModal: View {
    
    let store: StoreOf<TodaySelection>
    
    var body: some View {
        VStack {
            Text("학습 혹은 복습할 단어장을 골라주세요.")
                .font(.system(size: 20))
                .bold()
                .padding(.vertical, 10)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(store.sets, id: \.id) { set in
                        setCell(
                            set: set,
                            schedule: store.schedules[set] ?? .none,
                            studyButtonTapped: { store.send(.toggleStudy(set)) },
                            reviewButtonTapped: { store.send(.toggleReview(set)) }
                        )
                    }
                }
                
            }
        }
        .padding(.horizontal, 10)
        .onAppear { store.send(.fetchSets) }
    }
}

// MARK: SubViews

extension TodaySelectionModal {
    
    private func setCell(set: StudySet, schedule: Schedule, studyButtonTapped: @escaping () -> Void, reviewButtonTapped: @escaping () -> Void) -> some View {
        
        var dateTextColor: Color {
            switch schedule {
            case .none: return .black
            case .study: return .blue
            case .review: return .pink
            }
        }
        
        var dateText: String {
            let dayGap = set.dayFromToday
            return dayGap == 0 ? "今日" : "\(dayGap)日前"
        }
        
        var setInfo: some View {
            VStack(alignment: .leading) {
                Text(set.title)
                Text(dateText)
                    .foregroundColor(dateTextColor)
            }
        }
        
        var buttons: some View {
            VStack {
                Button("학습") { studyButtonTapped() }
                    .foregroundColor(schedule == .study ? Color.green : Color.black)
                Button("복습") { reviewButtonTapped() }
                    .foregroundColor(schedule == .review ? Color.green : Color.black)
            }
        }
        
        var body: some View {
            HStack {
                setInfo
                Spacer()
                buttons
            }
            .frame(height: 80)
            .padding(8)
            .font(.system(size: 24))
            .defaultRectangleBackground()
        }
        
        return body
    }
    
}

struct TodaySelectionModal_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodaySelectionModal(
                store: Store(
                    initialState: TodaySelection.State(
                        todaySets: [StudySet(index: 0), StudySet(index: 1), StudySet(index: 2)],
                        reviewSets: [StudySet(index: 3), StudySet(index: 4), StudySet(index: 5)]),
                    reducer: { TodaySelection()._printChanges() }
                )
            )
        }
    }
}

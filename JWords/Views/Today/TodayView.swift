//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct TodayList {
    @ObservableState
    struct State: Equatable {
        var todayStatus = TodayStatus.State()
        var reviewSets: [StudySet] = []
        
        @Presents var todaySelection: TodaySelection.State?
        
        mutating func clear() {
            reviewSets = []
            todayStatus.clear()
        }
        
    }
    
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    @Dependency(\.utilClient) var utilClient
    
    enum Action: Equatable {
        case onAppear
        case todayStatus(TodayStatus.Action)
        case listButtonTapped
        case clearScheduleButtonTapped
        case homeCellTapped(StudySet)
        case studyFilteredUnits([StudyUnit])
        case tutorialButtonTapped
        
        case todaySelection(PresentationAction<TodaySelection.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                fetchSchedule(&state)
            case .todaySelection(.dismiss):
                if let newStudy = state.todaySelection?.studySets,
                   let newReview = state.todaySelection?.reviewSets
                {
                    let newStudySets = scheduleClient.updateStudy(newStudy)
                    let newAllStudyUnits = try! unitClient.fetchAll(newStudySets)
                    let newToStudyUnits = utilClient.filterOnlyFailUnits(newAllStudyUnits)
                    state.todayStatus.update(
                        studySets: newStudySets,
                        allUnits: newAllStudyUnits,
                        toStudyUnits: newToStudyUnits)
                    state.reviewSets = scheduleClient.updateReview(newReview)
                }
            case .todayStatus(.onTapped):
                if state.todayStatus.isEmpty {
                    state.clear()
                    let sets = try! setClient.fetch(false)
                    scheduleClient.autoSet(sets)
                    fetchSchedule(&state)
                } else {
                    return .send(.studyFilteredUnits(state.todayStatus.toStudyUnits))
                }
            case .listButtonTapped:
                state.todaySelection = TodaySelection.State(todaySets: state.todayStatus.studySets,
                                                            reviewSets: state.reviewSets)
                state.todayStatus.clear()
                state.reviewSets = []
            case .clearScheduleButtonTapped:
                state.clear()
                scheduleClient.clear()
            default: break
            }
            return .none
        }
        .ifLet(\.$todaySelection, action: \.todaySelection) { TodaySelection() }
        Scope(state: \.todayStatus, action: \.todayStatus) { TodayStatus() }
    }
    
    private func fetchSchedule(_ state: inout TodayList.State) {
        state.clear()
        
        let allSets = try! setClient.fetch(false)
        let studySets = scheduleClient.study(allSets)
        let allUnits = try! unitClient.fetchAll(studySets)
        let studyUnits = utilClient.filterOnlyFailUnits(allUnits)
        
        state.todayStatus.update(
            studySets: studySets,
            allUnits: allUnits,
            toStudyUnits: studyUnits
        )
        
        state.reviewSets = scheduleClient.review(allSets)
    }

}

struct TodayView: View {
    
    @Bindable var store: StoreOf<TodayList>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("공부 단어장")
                        .font(.title)
                        .trailingAlignment()
                    TodayStatusView(store: store.scope(
                        state: \.todayStatus,
                        action: \.todayStatus)
                    )
                    .frame(height: 120)
                    VStack(spacing: 8) {
                        ForEach(store.todayStatus.studySets, id: \.id) { set in
                            SetCell(
                                title: set.title,
                                schedule: set.schedule,
                                dayFromToday: set.dayFromToday,
                                onTapped: { store.send(.homeCellTapped(set)) }
                            )
                        }
                    }
                }
                VStack(spacing: 20) {
                    Text("복습 단어장")
                        .font(.title)
                        .trailingAlignment()
                    VStack(spacing: 8) {
                        ForEach(store.reviewSets, id: \.id) { reviewSet in
                            SetCell(
                                title: reviewSet.title,
                                schedule: reviewSet.schedule,
                                dayFromToday: reviewSet.dayFromToday,
                                onTapped: { store.send(.homeCellTapped(reviewSet)) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .withBannerAD()
        .onAppear { store.send(.onAppear) }
        .sheet(item: $store.scope(state: \.todaySelection, action: \.todaySelection)) {
            TodaySelectionModal(store: $0)
        }
        .navigationTitle("오늘 단어장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem {
            HStack {
                Button {
                    store.send(.listButtonTapped)
                } label: {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .resizable()
                        .foregroundColor(.black)
                }
                Button {
                    store.send(.clearScheduleButtonTapped)
                } label: {
                    Image(systemName: "eraser")
                        .resizable()
                        .foregroundColor(.black)
                }
            }
        }}
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    store.send(.tutorialButtonTapped)
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .foregroundColor(.black)
                }
            }
        }
        #endif
    }
    
    private var statusLoadingView: some View {
        ZStack {
            Color.white.opacity(0)
            ProgressView()
                .scaleEffect(2)
        }
        .frame(height: 120)
        .defaultRectangleBackground()
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodayView(
                store: Store(
                    initialState: TodayList.State(),
                    reducer: { TodayList()._printChanges() }
                )
            )
        }
    }
}

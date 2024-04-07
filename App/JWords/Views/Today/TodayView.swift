//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture
import Model
import CommonUI
import tcaAPI

@Reducer
struct TodayList {
    @ObservableState
    struct State: Equatable {
        var todayStatus = TodayStatus.State()
        var reviewSets: [StudySet] = []
        
        @Presents var destination: Destination.State?
        
        mutating func clear() {
            reviewSets = []
            todayStatus.clear()
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case todaySelection(TodaySelection)
    }
    
    @Dependency(ScheduleClient.self) var scheduleClient
    @Dependency(StudySetClient.self) var setClient
    @Dependency(StudyUnitClient.self) var unitClient
    @Dependency(UtilClient.self) var utilClient
    
    enum Action: Equatable {
        case fetchSetsAndSchedule
        case todayStatus(TodayStatus.Action)
        case toSetSchedule
        case clearSchedule
        case toStudySet(StudySet)
        case toStudyFilteredUnits([StudyUnit])
        case showTutorial
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSetsAndSchedule:
                fetchSchedule(&state)
            case .destination(.dismiss):
                switch state.destination {
                case .todaySelection(let selectionState):
                    updateSchedule(&state, selectionState: selectionState)
                default: break
                }
            case .todayStatus(.onTapped):
                if state.todayStatus.isEmpty {
                    state.clear()
                    let sets = try! setClient.fetch(false)
                    scheduleClient.autoSet(sets)
                    fetchSchedule(&state)
                } else {
                    return .send(.toStudyFilteredUnits(state.todayStatus.toStudyUnits))
                }
            case .toSetSchedule:
                state.destination = .todaySelection(TodaySelection.State(todaySets: state.todayStatus.studySets,
                                                                         reviewSets: state.reviewSets))
                state.clear()
            case .clearSchedule:
                state.clear()
                scheduleClient.clear()
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
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
    
    func updateSchedule(_ state: inout TodayList.State, selectionState: TodaySelection.State) {
        let newStudy = selectionState.studySets
        let newReview = selectionState.reviewSets
        let newStudySets = scheduleClient.updateStudy(newStudy)
        let newAllStudyUnits = try! unitClient.fetchAll(newStudySets)
        let newToStudyUnits = utilClient.filterOnlyFailUnits(newAllStudyUnits)
        state.todayStatus.update(
            studySets: newStudySets,
            allUnits: newAllStudyUnits,
            toStudyUnits: newToStudyUnits)
        state.reviewSets = scheduleClient.updateReview(newReview)
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
                                onTapped: { store.send(.toStudySet(set)) }
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
                                onTapped: { store.send(.toStudySet(reviewSet)) }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .withBannerAD()
        .onAppear { store.send(.fetchSetsAndSchedule) }
        .sheet(item: $store.scope(state: \.destination?.todaySelection, action: \.destination.todaySelection)) {
            TodaySelectionModal(store: $0)
        }
        .navigationTitle("오늘 단어장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem {
            HStack {
                Button {
                    store.send(.toSetSchedule)
                } label: {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .resizable()
                        .foregroundColor(.black)
                }
                Button {
                    store.send(.clearSchedule)
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
                    store.send(.showTutorial)
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

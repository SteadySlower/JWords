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
    struct State: Equatable {
        var todayStatus = TodayStatus.State()
        var reviewSets: [StudySet] = []
        var studyUnitsInSet: StudyUnitsInSet.State?
        var studyUnits: StudyUnits.State?
        @PresentationState var todaySelection: TodaySelection.State?
        
        var showStudySetView: Bool {
            studyUnitsInSet != nil
        }
        
        var showStudyUnitsView: Bool {
            studyUnits != nil
        }
        
        var showTutorial: Bool = false
        
        mutating func clear() {
            reviewSets = []
            studyUnitsInSet = nil
            studyUnits = nil
            todaySelection = nil
            showTutorial = false
            todayStatus.clear()
        }
        
    }
    
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    @Dependency(\.utilClient) var utilClient
    
    enum Action: Equatable {
        case onAppear
        case studyUnitsInSet(StudyUnitsInSet.Action)
        case studyUnits(StudyUnits.Action)
        case todaySelection(PresentationAction<TodaySelection.Action>)
        case todayStatus(TodayStatus.Action)
        case listButtonTapped
        case clearScheduleButtonTapped
        case showStudySetView(Bool)
        case showStudyUnitsView(Bool)
        case showTutorial(Bool)
        case homeCellTapped(StudySet)
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
                    state.studyUnits = StudyUnits.State(units: state.todayStatus.toStudyUnits)
                }
            case .homeCellTapped(let set):
                let units = try! unitClient.fetch(set)
                state.studyUnitsInSet = StudyUnitsInSet.State(set: set, units: units)
            case .listButtonTapped:
                state.todaySelection = TodaySelection.State(todaySets: state.todayStatus.studySets,
                                                            reviewSets: state.reviewSets)
                state.todayStatus.clear()
                state.reviewSets = []
            case .clearScheduleButtonTapped:
                state.clear()
                scheduleClient.clear()
            case .showTutorial(let show):
                state.showTutorial = show
            case .studyUnitsInSet(.dismiss):
                state.studyUnitsInSet = nil
            default: break
            }
            return .none
        }
        .ifLet(\.studyUnitsInSet, action: \.studyUnitsInSet) { StudyUnitsInSet() }
        .ifLet(\.studyUnits, action: \.studyUnits) { StudyUnits() }
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
    let store: StoreOf<TodayList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
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
                            ForEach(vs.todayStatus.studySets, id: \.id) { set in
                                SetCell(
                                    title: set.title,
                                    schedule: set.schedule,
                                    dayFromToday: set.dayFromToday,
                                    onTapped: { vs.send(.homeCellTapped(set)) }
                                )
                            }
                        }
                    }
                    VStack(spacing: 20) {
                        Text("복습 단어장")
                            .font(.title)
                            .trailingAlignment()
                        VStack(spacing: 8) {
                            ForEach(vs.reviewSets, id: \.id) { reviewSet in
                                SetCell(
                                    title: reviewSet.title,
                                    schedule: reviewSet.schedule,
                                    dayFromToday: reviewSet.dayFromToday,
                                    onTapped: { vs.send(.homeCellTapped(reviewSet)) }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyUnitsInSet,
                                action: \.studyUnitsInSet)
                            ) { StudySetView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudySetView,
                                send: TodayList.Action.showStudySetView))
                { EmptyView() }
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyUnits,
                                action: \.studyUnits)
                            ) { StudyUnitsView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyUnitsView,
                                send: TodayList.Action.showStudyUnitsView))
                { EmptyView() }
                NavigationLink(
                    destination: TutorialList(),
                    isActive: vs.binding(
                                get: \.showTutorial,
                                send: TodayList.Action.showTutorial))
                { EmptyView() }
            }
            .withBannerAD()
            .onAppear { vs.send(.onAppear) }
            .sheet(store: store.scope(state: \.$todaySelection, action: \.todaySelection)) {
                TodaySelectionModal(store: $0)
            }
            .navigationTitle("오늘 단어장")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { ToolbarItem {
                HStack {
                    Button {
                        vs.send(.listButtonTapped)
                    } label: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .resizable()
                            .foregroundColor(.black)
                    }
                    Button {
                        vs.send(.clearScheduleButtonTapped)
                    } label: {
                        Image(systemName: "eraser")
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
            }}
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vs.send(.showTutorial(true))
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
            }
            #endif
        }
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
        NavigationView {
            TodayView(
                store: Store(
                    initialState: TodayList.State(),
                    reducer: { TodayList()._printChanges() }
                )
            )
        }
    }
}

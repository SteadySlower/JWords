//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

struct TodayList: Reducer {
    struct State: Equatable {
        var todayStatus = TodayStatus.State()
        var reviewSets: [StudySet] = []
        var studyUnitsInSet: StudyUnitsInSet.State?
        var studyUnits: StudyUnits.State?
        var todaySelection: TodaySelection.State?
        
        var showStudySetView: Bool {
            studyUnitsInSet != nil
        }
        
        var showStudyUnitsView: Bool {
            studyUnits != nil
        }
        
        var showModal: Bool {
            todaySelection != nil
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
        case todaySelection(TodaySelection.Action)
        case todayStatus(TodayStatus.Action)
        case setSelectionModal(Bool)
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
                return .none
            case .setSelectionModal(let isPresent):
                if !isPresent {
                    if let newStudy = state.todaySelection?.studySets {
                        scheduleClient.updateStudy(newStudy)
                    }
                    if let newReview = state.todaySelection?.reviewSets {
                        scheduleClient.updateReview(newReview)
                    }
                    state.todaySelection = nil
                    return .send(.onAppear)
                }
                return .none
            case .todayStatus(let action):
                switch action {
                case .onTapped:
                    if state.todayStatus.isEmpty {
                        state.clear()
                        let sets = try! setClient.fetch(false)
                        scheduleClient.autoSet(sets)
                        fetchSchedule(&state)
                        return .none
                    } else {
                        state.studyUnits = StudyUnits.State(units: state.todayStatus.toStudyUnits)
                        return .none
                    }
                default: return .none
                }
            case .homeCellTapped(let set):
                let units = try! unitClient.fetch(set)
                state.studyUnitsInSet = StudyUnitsInSet.State(set: set, units: units)
                return .none
            case .listButtonTapped:
                state.todaySelection = TodaySelection.State(todaySets: state.todayStatus.studySets,
                                                            reviewSets: state.reviewSets)
                return .none
            case .clearScheduleButtonTapped:
                state.clear()
                scheduleClient.clear()
                return .none
            case .showTutorial(let show):
                state.showTutorial = show
                return .none
            case .studyUnitsInSet(let action):
                switch action {
                case .dismiss:
                    state.studyUnitsInSet = nil
                    return .none
                default: return .none
                }
            default:
                return .none
            }
        }
        .ifLet(\.studyUnitsInSet, action: /Action.studyUnitsInSet) {
            StudyUnitsInSet() 
        }
        .ifLet(\.studyUnits, action: /Action.studyUnits) {
            StudyUnits()
        }
        .ifLet(\.todaySelection, action: /Action.todaySelection) {
            TodaySelection()
        }
        Scope(
            state: \.todayStatus,
            action: /Action.todayStatus,
            child: { TodayStatus() }
        )
    }
    
    private func fetchSchedule(_ state: inout TodayList.State) {
        state.clear()
        
        let allSets = try! setClient.fetch(false)
        let studySets = scheduleClient.study(allSets)
        let allUnits = try! unitClient.fetchAll(allSets)
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
                            action: TodayList.Action.todayStatus)
                        )
                        .frame(height: 120)
                        VStack(spacing: 8) {
                            ForEach(vs.todayStatus.studySets, id: \.id) { set in
                                HomeCell(studySet: set) {
                                    vs.send(.homeCellTapped(set))
                                }
                            }
                        }
                    }
                    VStack(spacing: 20) {
                        Text("복습 단어장")
                            .font(.title)
                            .trailingAlignment()
                        VStack(spacing: 8) {
                            ForEach(vs.reviewSets, id: \.id) { reviewSet in
                                HomeCell(studySet: reviewSet) {
                                    vs.send(.homeCellTapped(reviewSet))
                                }
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
                                action: TodayList.Action.studyUnitsInSet)
                            ) { StudySetView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudySetView,
                                send: TodayList.Action.showStudySetView))
                { EmptyView() }
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyUnits,
                                action: TodayList.Action.studyUnits)
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
            .sheet(isPresented: vs.binding(
                get: \.showModal,
                send: TodayList.Action.setSelectionModal)
            ) {
                IfLetStore(store.scope(
                    state: \.todaySelection,
                    action: TodayList.Action.todaySelection)
                ) {
                    TodaySelectionModal(store: $0)
                }
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

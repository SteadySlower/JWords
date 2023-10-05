//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

struct TodayList: ReducerProtocol {
    struct State: Equatable {
        var studySets: [StudySet] = []
        var reviewSets: [StudySet] = []
        var reviewedSets: [StudySet] = []
        var onlyFailUnits: [StudyUnit] = []
        var todayStatus: TodayStatus?
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
        
        fileprivate mutating func clear() {
            studySets = []
            reviewSets = []
            onlyFailUnits = []
            todayStatus = nil
            studyUnitsInSet = nil
            studyUnits = nil
            todaySelection = nil
            showTutorial = false
        }
        
        fileprivate mutating func addTodaySets(todaySets: TodaySets) {
            studySets = todaySets.study
            reviewedSets = todaySets.reviewed
            reviewSets = todaySets.review.filter { !reviewedSets.contains($0) }
        }
        
    }
    
    @Dependency(\.scheduleClient) var scheduleClient
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case studyUnitsInSet(StudyUnitsInSet.Action)
        case studyUnits(StudyUnits.Action)
        case todaySelection(TodaySelection.Action)
        case setSelectionModal(Bool)
        case listButtonTapped
        case clearScheduleButtonTapped
        case showStudySetView(Bool)
        case showStudyUnitsView(Bool)
        case showTutorial(Bool)
        case todayStatusTapped
        case homeCellTapped(StudySet)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                fetchSchedule(&state)
                return .none
            case .onDisappear:
                state.todayStatus = nil
                return .none
            case .setSelectionModal(let isPresent):
                if !isPresent {
                    guard let newSchedule = state.todaySelection?.newSchedule else { return .none }
                    scheduleClient.update(newSchedule)
                    state.todaySelection = nil
                    return .task { .onAppear }
                }
                return .none
            case .todayStatusTapped:
                if state.todayStatus == .empty {
                    state.clear()
                    let sets = try! setClient.fetch(false)
                    scheduleClient.autoSet(sets)
                    fetchSchedule(&state)
                    return .none
                } else {
                    state.studyUnits = StudyUnits.State(units: state.onlyFailUnits)
                    return .none
                }
            case .homeCellTapped(let set):
                let units = try! unitClient.fetch(set)
                state.studyUnitsInSet = StudyUnitsInSet.State(set: set, units: units)
                return .none
            case .listButtonTapped:
                state.todayStatus = nil
                state.todaySelection = TodaySelection.State(todaySets: state.studySets,
                                                            reviewSets: state.reviewSets,
                                                            reviewedSets: state.reviewedSets)
                return .none
            case .clearScheduleButtonTapped:
                state.clear()
                scheduleClient.update(.empty)
                fetchSchedule(&state)
                return .task  { .onAppear }
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
    }
    
    private func fetchSchedule(_ state: inout TodayList.State) {
        state.clear()
        let todaySets = TodaySets(sets: try! setClient.fetch(false), schedule: scheduleClient.fetch())
        state.addTodaySets(todaySets: todaySets)
        let todayWords = todaySets.study
            .map { try! unitClient.fetch($0) }
            .reduce([], +)
        state.onlyFailUnits = todayWords
                    .filter { $0.studyState != .success }
                    .removeOverlapping()
                    .sorted(by: { $0.createdAt < $1.createdAt })
        state.todayStatus = .init(
            sets: todaySets.study.count,
            total: todayWords.count,
            wrong: state.onlyFailUnits.count)
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
                        if let todayStatus = vs.todayStatus {
                            TodayStatusView(status: todayStatus) {
                                vs.send(.todayStatusTapped)
                            }
                            .frame(height: 120)
                        } else {
                            statusLoadingView
                        }
                        VStack(spacing: 8) {
                            ForEach(vs.studySets, id: \.id) { set in
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
            .onDisappear { vs.send(.onDisappear) }
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
                    reducer: TodayList()._printChanges()
                )
            )
        }
    }
}

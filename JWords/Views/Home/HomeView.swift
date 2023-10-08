//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct HomeList: Reducer {
    struct State: Equatable {
        var sets: [StudySet] = []
        var studyUnitsInSet: StudyUnitsInSet.State?
        var addSet: AddSet.State?
        var isLoading: Bool = false
        var includeClosed: Bool = false
        
        var showStudySetView: Bool {
            studyUnitsInSet != nil
        }
        
        var showAddSetModal: Bool {
            addSet != nil
        }
        
        mutating func clear() {
            sets = []
            studyUnitsInSet = nil
            addSet = nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case homeCellTapped(StudySet)
        case setAddSetModal(Bool)
        case showStudySetView(Bool)
        case updateIncludeClosed(Bool)
        case studyUnitsInSet(StudyUnitsInSet.Action)
        case addSet(AddSet.Action)
    }
    
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.sets = try! setClient.fetch(state.includeClosed)
                return .none
            case .setAddSetModal(let isPresent):
                state.addSet = isPresent ? AddSet.State() : nil
                return .none
            case let .homeCellTapped(set):
                let units = try! unitClient.fetch(set)
                state.studyUnitsInSet = StudyUnitsInSet.State(set: set, units: units)
                return .none
            case .updateIncludeClosed(let bool):
                state.includeClosed = bool
                return .send(.onAppear)
            case .studyUnitsInSet(let action):
                switch action {
                case .dismiss:
                    state.studyUnitsInSet = nil
                    return .none
                default: return .none
                }
            case .addSet(let action):
                switch action {
                case .added(let set):
                    state.sets.insert(set, at: 0)
                    state.addSet = nil
                    return .none
                case .cancel:
                    state.addSet = nil
                    return .none
                default:
                    return .none
                }
            default:
                return .none
            }
        }
        .ifLet(\.studyUnitsInSet, action: /Action.studyUnitsInSet) {
            StudyUnitsInSet()
        }
        .ifLet(\.addSet, action: /Action.addSet) {
            AddSet()
        }
    }

}

struct HomeView: View {
    
    let store: StoreOf<HomeList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Picker("닫힌 단어장", selection: vs.binding(
                    get: \.includeClosed,
                    send: HomeList.Action.updateIncludeClosed)
                ) {
                    Text("열린 단어장")
                        .tag(false)
                    Text("모든 단어장")
                        .tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 100)
                .padding(.top, 20)
                ScrollView {
                    VStack(spacing: 8) {
                        VStack {
                            
                        }
                        .frame(height: 20)
                        ForEach(vs.sets, id: \.id) { set in
                            HomeCell(studySet: set) { vs.send(.homeCellTapped(set)) }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyUnitsInSet,
                                action: HomeList.Action.studyUnitsInSet)
                            ) { StudySetView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudySetView,
                                send: HomeList.Action.showStudySetView))
                { EmptyView() }
            }
            .withBannerAD()
            .navigationTitle("모든 단어장")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
            .sheet(isPresented: vs.binding(
                get: \.showAddSetModal,
                send: HomeList.Action.setAddSetModal)
            ) {
                IfLetStore(store.scope(state: \.addSet,
                                            action: HomeList.Action.addSet)
                ) {
                    AddSetView(store: $0)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        vs.send(.setAddSetModal(true))
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                store: Store(
                    initialState: HomeList.State(),
                    reducer: { HomeList()._printChanges() }
                )
            )
        }
    }
}

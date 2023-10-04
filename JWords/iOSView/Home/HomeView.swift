//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct HomeList: ReducerProtocol {
    struct State: Equatable {
        var wordBooks:[StudySet] = []
        var studyBook: StudyBook.State?
        var addSet: AddSet.State?
        var isLoading: Bool = false
        var includeClosed: Bool = false
        
        var showStudyView: Bool {
            studyBook != nil
        }
        
        var showBookInputModal: Bool {
            addSet != nil
        }
        
        mutating func clear() {
            wordBooks = []
            studyBook = nil
            addSet = nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case homeCellTapped(StudySet)
        case setInputBookModal(Bool)
        case showStudyView(Bool)
        case updateIncludeClosed(Bool)
        case studyBook(StudyBook.Action)
        case addSet(AddSet.Action)
    }
    
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.wordBooks = try! setClient.fetch(state.includeClosed)
                return .none
            case .setInputBookModal(let isPresent):
                state.addSet = isPresent ? AddSet.State() : nil
                return .none
            case let .homeCellTapped(set):
                let units = try! unitClient.fetch(set)
                state.studyBook = StudyBook.State(set: set, units: units)
                return .none
            case .updateIncludeClosed(let bool):
                state.includeClosed = bool
                return .task { .onAppear }
            case .studyBook(let action):
                switch action {
                case .dismiss:
                    state.studyBook = nil
                    return .none
                default: return .none
                }
            case .addSet(let action):
                switch action {
                case .added:
                    state.wordBooks = try! setClient.fetch(state.includeClosed)
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
        .ifLet(\.studyBook, action: /Action.studyBook) {
            StudyBook()
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
                        ForEach(vs.wordBooks, id: \.id) { wordBook in
                            HomeCell(studySet: wordBook) { vs.send(.homeCellTapped(wordBook)) }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyBook,
                                action: HomeList.Action.studyBook)
                            ) { StudyBookView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyView,
                                send: HomeList.Action.showStudyView))
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
                get: \.showBookInputModal,
                send: HomeList.Action.setInputBookModal)
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
                        vs.send(.setInputBookModal(true))
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
                    reducer: HomeList()._printChanges()
                )
            )
        }
    }
}

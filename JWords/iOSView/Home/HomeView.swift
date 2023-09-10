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
        var wordList: WordList.State?
        var inputBook: InputBook.State?
        var isLoading: Bool = false
        var includeClosed: Bool = false
        
        var showStudyView: Bool {
            wordList != nil
        }
        
        var showBookInputModal: Bool {
            inputBook != nil
        }
        
        mutating func clear() {
            wordBooks = []
            wordList = nil
            inputBook = nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case homeCellTapped(StudySet)
        case setInputBookModal(isPresent: Bool)
        case showStudyView(Bool)
        case updateIncludeClosed(Bool)
        case wordList(action: WordList.Action)
        case inputBook(action: InputBook.Action)
    }
    
    let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.wordBooks = try! cd.fetchSets()
                return .none
            case .setInputBookModal(let isPresent):
                state.inputBook = isPresent ? InputBook.State() : nil
                return .none
            case let .homeCellTapped(wordBook):
                state.wordList = WordList.State(set: wordBook)
                return .none
            case .updateIncludeClosed(let bool):
                state.includeClosed = bool
                return .none
            case .wordList(let action):
                if action == WordList.Action.dismiss {
                    state.wordList = nil
                }
                return .none
            case .inputBook(let action):
                switch action {
                case .setAdded:
                    state.wordBooks = try! cd.fetchSets()
                    state.inputBook = nil
                    return .none
                case .cancelButtonTapped:
                    state.inputBook = nil
                    return .none
                default:
                    return .none
                }
            default:
                return .none
            }
        }
        .ifLet(\.wordList, action: /Action.wordList(action:)) {
            WordList()
        }
        .ifLet(\.inputBook, action: /Action.inputBook(action:)) {
            InputBook()
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
                                state: \.wordList,
                                action: HomeList.Action.wordList(action:))
                            ) { StudyView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyView,
                                send: HomeList.Action.showStudyView))
                { EmptyView() }
            }
            .navigationTitle("단어장 목록")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
            .sheet(isPresented: vs.binding(
                get: \.showBookInputModal,
                send: HomeList.Action.setInputBookModal(isPresent:))
            ) {
                IfLetStore(self.store.scope(state: \.inputBook,
                                            action: HomeList.Action.inputBook(action:))
                ) {
                    WordBookAddModal(store: $0)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        vs.send(.setInputBookModal(isPresent: true))
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

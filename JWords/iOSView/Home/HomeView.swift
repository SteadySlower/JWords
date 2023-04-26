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
        var wordBooks:[WordBook] = []
        var wordList: WordList.State?
        var isLoading: Bool = false
        
        var showStudyView: Bool {
            wordList != nil
        }
        
        mutating func clear() {
            wordBooks = []
            wordList = nil
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case wordBookResponse(TaskResult<[WordBook]>)
        case homeCellTapped(WordBook)
        case setAddBookModal(isPresent: Bool)
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.isLoading = true
                return .task {
                    await .wordBookResponse(TaskResult { try await wordBookClient.wordBooks() })
                }
            case let .wordBookResponse(.success(books)):
                state.wordBooks = books
                state.isLoading = false
                return .none
            case let .homeCellTapped(wordBook):
                state.wordList = WordList.State(wordBook: wordBook)
                return .none
            default:
                return .none
            }
        }
    }

}

struct HomeView: View {
    
    let store: StoreOf<HomeList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(vs.wordBooks, id: \.id) { wordBook in
                        HomeCell(wordBook: wordBook) { vs.send(.homeCellTapped(wordBook)) }
                    }
                }
            }
            .navigationTitle("단어장 목록")
            .onAppear { vs.send(.onAppear) }
//            .sheet(isPresented: vs.binding(
//                get: \.showModal,
//                send: TodayList.Action.setSelectionModal(isPresent:))
//            ) {
//                IfLetStore(self.store.scope(state: \.todaySelection, action: TodayList.Action.todaySelection(action:))) {
//                    TodaySelectionModal(store: $0)
//                }
//            }
            .toolbar {
                ToolbarItem {
                    Button("+") {  }
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

// MARK: SubViews
extension HomeView {
    private struct WordBookAddModal: View {
        @State var title: String = ""
        @State var preferredFrontType: FrontType = .kanji
        @Environment(\.dismiss) var dismiss
        private let viewModel: ViewModel
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack {
                TextField("단어장 이름", text: $title)
                    .padding()
                Picker("", selection: $preferredFrontType) {
                    ForEach(FrontType.allCases, id: \.self) {
                        Text($0.preferredTypeText)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                HStack {
                    Button("추가", action: {
                        viewModel.AddWordBook(title: title, preferredFrontType: preferredFrontType)
                        dismiss()
                    })
                    Button("취소", role: .cancel, action: { dismiss() })
                }
            }
            .padding()
        }
    }
}

extension HomeView {
    final class ViewModel: ObservableObject {
        @Published private(set) var wordBooks: [WordBook] = []
        private let wordBookService: WordBookService
        
        init(wordBookService: WordBookService) {
            self.wordBookService = wordBookService
        }
        
        func fetchWordBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                if let error = error { print("디버그: \(error.localizedDescription)"); return }
                if let wordBooks = wordBooks {
                    self?.wordBooks = wordBooks
                }
            }
        }
        
        func AddWordBook(title: String, preferredFrontType: FrontType) {
            wordBookService.saveBook(title: title, preferredFrontType: preferredFrontType) { [weak self] error in
                if let error = error {
                    print(error)
                    return
                }
                self?.fetchWordBooks()
            }
        }
    }
}

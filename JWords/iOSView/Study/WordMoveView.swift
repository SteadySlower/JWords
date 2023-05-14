//
//  WordMoveView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/21.
//

import SwiftUI
import ComposableArchitecture

struct MoveWords: ReducerProtocol {
    struct State: Equatable {
        let fromBook: StudySet
        let toMoveWords: [StudyUnit]
        var wordBooks = [StudySet]()
        var selectedID: String? = nil
        var isLoading: Bool = false
        var willCloseBook: Bool
        
        init(fromBook: StudySet, toMoveWords: [StudyUnit]) {
            self.fromBook = fromBook
            self.toMoveWords = toMoveWords
            self.willCloseBook = fromBook.dayFromToday >= 28 ? true : false
        }
        
        var selectedWordBook: StudySet? {
            if let selectedID = selectedID {
                return wordBooks.first(where: { $0.id == selectedID })
            } else {
                return nil
            }
        }
    }
    
    let ud = UserDefaultClient.shared
    let cd = CoreDataClient.shared
    
    enum Action: Equatable {
        case onAppear
        case updateSelection(String?)
        case updateWillCloseBook(willClose: Bool)
        case closeButtonTapped
        case cancelButtonTapped
        case onMoved
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.todayClient) var todayClient
    private enum FetchWordBooksID {}
    private enum MoveWordsID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.wordBooks = try! cd.fetchSets().filter { $0.id != state.fromBook.id }
                state.isLoading = false
                return .none
            case .updateSelection(let id):
                state.selectedID = id
                return .none
            case .updateWillCloseBook(let willClose):
                state.willCloseBook = willClose
                return .none
            case .closeButtonTapped:
                state.isLoading = true
                if let toBook = state.selectedWordBook {
                    try! cd.moveUnits(state.toMoveWords,
                                      from: state.fromBook,
                                      to: toBook)
                }
                if state.willCloseBook {
                    let toClose = state.fromBook
                    _ = try! cd.updateSet(toClose,
                                          title: toClose.title,
                                          isAutoSchedule: toClose.isAutoSchedule,
                                          preferredFrontType: toClose.preferredFrontType,
                                          closed: true)
                }
                state.isLoading = false
                return .task { .onMoved }
            default:
                return .none
            }
        }
    }
}

struct WordMoveView: View {
    let store: StoreOf<MoveWords>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("\(vs.toMoveWords.count)개의 단어들을 이동할 단어장을 골라주세요.")
                Picker("이동할 단어장 고르기", selection: vs.binding(
                    get: \.selectedID,
                    send: MoveWords.Action.updateSelection)
                ) {
                    Text(vs.wordBooks.isEmpty ? "로딩중" : "이동 안함")
                        .tag(nil as String?)
                    ForEach(vs.wordBooks, id: \.id) {
                        Text($0.title)
                            .tag($0.id as String?)
                    }
                }
                #if os(iOS)
                .pickerStyle(.wheel)
                #endif
                Toggle("단어장 마감하기", isOn: vs.binding(
                    get: \.willCloseBook,
                    send: MoveWords.Action.updateWillCloseBook(willClose:))
                )
                .padding(.horizontal, 20)
                HStack {
                    Button("취소") {
                        vs.send(.cancelButtonTapped)
                    }
                    Button(vs.selectedID != nil ? "이동" : "닫기") {
                        vs.send(.closeButtonTapped)
                    }
                    .disabled(vs.isLoading)
                }
            }
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
        }
    }
    
}

struct WordMoveView_Previews: PreviewProvider {
    static var previews: some View {
        WordMoveView(
            store: Store(
                initialState: MoveWords.State(fromBook: StudySet(index: 0),
                                              toMoveWords: .mock),
                reducer: MoveWords()._printChanges()
            )
        )
    }
}

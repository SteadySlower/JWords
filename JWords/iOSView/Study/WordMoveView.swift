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
        case onMoved(from: StudySet)
    }
    
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
                return .task { [from = state.fromBook] in .onMoved(from: from) }
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
            VStack(spacing: 20) {
                Text("\(vs.toMoveWords.count)개의 단어 이동하기")
                    .font(.system(size: 35))
                    .bold()
                VStack {
                    Text("단어장 선택")
                        .font(.system(size: 20))
                        .bold()
                        .leadingAlignment()
                        .padding(.leading, 10)
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
                }
                VStack {
                    Toggle("현재 단어장 마감",
                        isOn: vs.binding(
                            get: \.willCloseBook,
                            send: MoveWords.Action.updateWillCloseBook(willClose:))
                    )
                    .tint(.black)
                }
                HStack {
                    button("취소", foregroundColor: .black) {
                        vs.send(.cancelButtonTapped)
                    }
                    button("확인", foregroundColor: vs.isLoading ? .gray : .black) {
                        vs.send(.closeButtonTapped)
                    }
                    .disabled(vs.isLoading)
                }
            }
            .padding(.horizontal, 10)
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
        }
    }
    
    private func button(_ text: String, foregroundColor: Color, onTapped: @escaping () -> Void) -> some View {
        Button {
            onTapped()
        } label: {
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(foregroundColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .defaultRectangleBackground()
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

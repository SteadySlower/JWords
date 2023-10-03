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
        let isReviewBook: Bool
        let toMoveWords: [StudyUnit]
        var wordBooks = [StudySet]()
        var selectedID: String? = nil
        var isLoading: Bool = false
        var willCloseBook: Bool
        
        init(fromBook: StudySet, isReviewBook: Bool, toMoveWords: [StudyUnit]) {
            self.fromBook = fromBook
            self.isReviewBook = isReviewBook
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
    
    let kv = KVStorageClient.shared
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.studyUnitClient) var unitClient
    
    enum Action: Equatable {
        case onAppear
        case updateSelection(String?)
        case updateWillCloseBook(willClose: Bool)
        case closeButtonTapped
        case cancelButtonTapped
        case onMoved
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.wordBooks = try! setClient.fetch(false).filter { $0.id != state.fromBook.id }
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
                    try! unitClient.move(state.toMoveWords, state.fromBook, toBook)
                }
                if state.willCloseBook {
                    try! setClient.close(state.fromBook)
                }
                if state.isReviewBook {
                    kv.addReviewedSet(reviewed: state.fromBook)
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
                if vs.isReviewBook {
                    Text("현재 단어장은 복습 리스트에 있습니다.\n단어를 이동하면 복습 리스트에서 제외됩니다.")
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
                                              isReviewBook: true,
                                              toMoveWords: .mock),
                reducer: MoveWords()._printChanges()
            )
        )
    }
}

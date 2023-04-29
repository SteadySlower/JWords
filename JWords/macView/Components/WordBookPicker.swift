//
//  WordBookPicker.swift
//  JWords
//
//  Created by JW Moon on 2023/04/29.
//

import SwiftUI
import ComposableArchitecture

struct SelectWordBook: ReducerProtocol {
    
    struct State: Equatable {
        var wordBooks = [WordBook]()
        var selectedID: String? = nil
        var wordCount: Int? = nil
        var didFetched = false
        
        var pickerDefaultText: String {
            if didFetched && !wordBooks.isEmpty {
                return "단어장을 선택해주세요"
            } else if didFetched && wordBooks.isEmpty {
                return "단어장 리스트 불러오기 실패"
            } else {
                return "단어장 불러오는 중..."
            }
        }
    }
    
    enum Action: Equatable {
        case updateID(String?)

    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}

struct WordBookPicker: View {
    
    let store: StoreOf<SelectWordBook>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            HStack {
                Picker("", selection:
                        vs.binding(
                             get: \.selectedID,
                             send: SelectWordBook.Action.updateID)
                ) {
                    Text(vs.pickerDefaultText)
                        .tag(nil as String?)
                    ForEach(vs.wordBooks, id: \.id) { book in
                        Text(book.title)
                            .tag(book.id as String?)
                    }
                }
                Text("단어 수: \(vs.wordCount ?? 0)개")
                    .hide(vs.selectedID == nil)
            }
            .padding()
        }
    }
}

struct WordBookPicker_Previews: PreviewProvider {
    static var previews: some View {
        WordBookPicker(
            store: Store(
                initialState: SelectWordBook.State(),
                reducer: SelectWordBook()._printChanges()
            )
        )
    }
}

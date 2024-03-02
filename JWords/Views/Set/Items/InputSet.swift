//
//  InputSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct InputSet {
    @ObservableState
    struct State: Equatable {
        var title: String
        var frontType: FrontType
        
        init(
            title: String = "",
            frontType: FrontType = .kanji
        ) {
            self.title = title
            self.frontType = frontType
        }
    }
    
    enum Action: Equatable {
        case updateTitle(String)
        case updateFrontType(FrontType)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateTitle(let title):
                state.title = title
                return .none
            case .updateFrontType(let frontType):
                state.frontType = frontType
                return .none
            }
        }
    }
    
}

struct InputSetView: View {
    
    @Bindable var store: StoreOf<InputSet>
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                InputFieldTitle(title: "단어장 이름")
                InputSetTextField(
                    placeHolder: "단어장 이름",
                    text: $store.title.sending(\.updateTitle)
                )
            }
            VStack {
                InputFieldTitle(title: "앞면 유형")
                Picker("", selection: $store.frontType.sending(\.updateFrontType)
                ) {
                    ForEach(FrontType.allCases, id: \.self) {
                        Text($0.preferredTypeText)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
}

#Preview {
    InputSetView(store: Store(
        initialState: InputSet.State(),
        reducer: { InputSet() })
    )
}

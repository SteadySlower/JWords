//
//  File.swift
//  
//
//  Created by JW Moon on 4/21/24.
//

import ComposableArchitecture
import SwiftUI
import Model

@Reducer
public struct InputSet {
    @ObservableState
    public struct State: Equatable {
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
    
    public enum Action: Equatable {
        case setTitle(String)
        case setFrontType(FrontType)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setTitle(let title):
                state.title = title
                return .none
            case .setFrontType(let frontType):
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
                    text: $store.title.sending(\.setTitle)
                )
            }
            VStack {
                InputFieldTitle(title: "앞면 유형")
                Picker("", selection: $store.frontType.sending(\.setFrontType)
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

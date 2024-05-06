//
//  File.swift
//  
//
//  Created by JW Moon on 5/6/24.
//

import ComposableArchitecture
import SwiftUI
import CommonSet
import CommonUI
import Model

public struct InputSetView: View {
    
    @Bindable var store: StoreOf<InputSet>
    
    public init(store: StoreOf<InputSet>) {
        self.store = store
    }
    
    public var body: some View {
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


//
//  AddSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI
import CommonUI

struct AddSetView: View {
    
    let store: StoreOf<AddSet>
    
    var body: some View {
        VStack(spacing: 30) {
            InputSetView(store: store.scope(
                state: \.inputSet,
                action: \.inputSet)
            )
            HStack {
                Spacer()
                Button("취소") {
                    store.send(.cancel)
                }
                .buttonStyle(InputButtonStyle())
                Spacer()
                Button("추가") {
                    store.send(.add)
                }
                .buttonStyle(InputButtonStyle(isAble: store.ableToAdd))
                .disabled(!store.ableToAdd)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .presentationDetents([.medium])
    }
}

#Preview {
    AddSetView(store: Store(
        initialState: AddSet.State(),
        reducer: { AddSet() })
    )
}


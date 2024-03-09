//
//  EditSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditSet {
    @ObservableState
    struct State: Equatable {
        let set: StudySet
        var inputSet: InputSet.State
        
        var ableToEdit: Bool {
            !inputSet.title.isEmpty
        }
        
        init(_ set: StudySet) {
            self.set = set
            self.inputSet = .init(
                title: set.title,
                frontType: set.preferredFrontType)
        }
    }
    
    enum Action: Equatable {
        case inputSet(InputSet.Action)
        case edit
        case cancel
        case edited(StudySet)
    }
    
    @Dependency(\.studySetClient) var setClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .edit:
                let input = StudySetInput(
                    title: state.inputSet.title,
                    isAutoSchedule: true,
                    preferredFrontType: state.inputSet.frontType
                )
                let edited = try! setClient.update(state.set, input)
                return .send(.edited(edited))
            case .cancel:
                return .run { _ in await self.dismiss() }
            default: break
            }
            return .none
        }
        Scope(state: \.inputSet, action: \.inputSet) { InputSet() }
    }
    
}

struct EditSetView: View {
    
    let store: StoreOf<EditSet>
    
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
                Button("수정") {
                    store.send(.edit)
                }
                .buttonStyle(InputButtonStyle(isAble: store.ableToEdit))
                .disabled(!store.ableToEdit)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .presentationDetents([.medium])
    }
}

#Preview {
    EditSetView(store: Store(
        initialState: EditSet.State(.init(index: 0)),
        reducer: { EditSet() })
    )
}


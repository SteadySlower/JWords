//
//  StudySetPicker.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SelectStudySet {
    @ObservableState
    struct State: Equatable {
        var sets: [StudySet]
        var selectedID: String?
        var unitCount: Int?
        
        init(
            sets: [StudySet] = [],
            selectedID: String? = nil,
            unitCount: Int? = nil
        ) {
            self.sets = sets
            self.selectedID = selectedID
            self.unitCount = unitCount
        }
        
        var selectedSet: StudySet? {
            sets.first(where: { $0.id == selectedID })
        }
        
        var pickerDefaultText: String {
            !sets.isEmpty ? "단어장을 선택해주세요" : "단어장 없음"
        }
        
        mutating func onUnitAdded() {
            self.unitCount? += 1
        }
        
        mutating func resetState() {
            sets = []
            selectedID = nil
            unitCount = nil
        }
    }
    
    @Dependency(\.studySetClient) var setClient
    
    enum Action: Equatable {
        case fetchSets
        case updateID(String?)
        case idUpdated(StudySet?)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                state.sets = try! setClient.fetch(false)
                return .none
            case .updateID(let id):
                state.selectedID = id
                if let set = state.selectedSet {
                    state.unitCount = try! setClient.countUnits(set)
                } else {
                    state.unitCount = nil
                }
                return .send(.idUpdated(state.selectedSet))
            default:
                return .none
            }
        }
    }
}

struct StudySetPicker: View {
    
    @Bindable var store: StoreOf<SelectStudySet>
    let pickerName: String
    
    var body: some View {
        VStack {
            Text("단어장 선택")
                .font(.system(size: 20))
                .bold()
                .leadingAlignment()
                .padding(.leading, 10)
            HStack {
                Picker(pickerName, selection: $store.selectedID.sending(\.updateID)) {
                    Text(store.pickerDefaultText.localize())
                        .tag(nil as String?)
                    ForEach(store.sets, id: \.id) { studySet in
                        Text(studySet.title)
                            .tag(studySet.id as String?)
                    }
                }
                .tint(.black)
                Spacer()
                Text("단어 수: \(store.unitCount ?? 0)개")
                .opacity(store.selectedID == nil ? 0 : 1)
            }
            .onAppear { store.send(.fetchSets) }
        }
    }
}

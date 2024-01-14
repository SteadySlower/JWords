//
//  StudySetPicker.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct SelectStudySet: Reducer {
    
    struct State: Equatable {
        var sets: [StudySet]
        var selectedID: String?
        var unitCount: Int?
        let pickerName: String
        
        init(
            sets: [StudySet] = [],
            selectedID: String? = nil,
            unitCount: Int? = nil,
            pickerName: String = ""
        ) {
            self.sets = sets
            self.selectedID = selectedID
            self.unitCount = unitCount
            self.pickerName = pickerName
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
        case onAppear
        case updateID(String?)
        case idUpdated(StudySet?)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.sets = try! setClient.fetch(false)
                return .none
            case .updateID(let id):
                state.selectedID = id
                state.unitCount = nil
                defer {
                    if let set = state.selectedSet {
                        state.unitCount = try! setClient.countUnits(set)
                    }
                }
                return .send(.idUpdated(state.selectedSet))
            default:
                return .none
            }
        }
    }
}

struct StudySetPicker: View {
    
    let store: StoreOf<SelectStudySet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("단어장 선택")
                    .font(.system(size: 20))
                    .bold()
                    .leadingAlignment()
                    .padding(.leading, 10)
                HStack {
                    Picker(vs.pickerName, selection:
                            vs.binding(
                                 get: \.selectedID,
                                 send: SelectStudySet.Action.updateID)
                    ) {
                        Text(vs.pickerDefaultText.localize())
                            .tag(nil as String?)
                        ForEach(vs.sets, id: \.id) { studySet in
                            Text(studySet.title)
                                .tag(studySet.id as String?)
                        }
                    }
                    .tint(.black)
                    Spacer()
                    Text("단어 수: \(vs.unitCount ?? 0)개")
                    .opacity(vs.selectedID == nil ? 0 : 1)
                }
                .onAppear { vs.send(.onAppear) }
            }
        }
    }
}

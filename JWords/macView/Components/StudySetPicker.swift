//
//  StudySetPicker.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct SelectStudySet: ReducerProtocol {
    
    struct State: Equatable {
        var sets = [StudySet]()
        var selectedID: String? = nil
        var unitCount: Int? = nil
        let pickerName: String
        
        init(pickerName: String = "") {
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
    
    private let cd = CoreDataService.shared
    
    enum Action: Equatable {
        case onAppear
        case updateID(String?)
        case idUpdated
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.sets = try! cd.fetchSets()
                return .none
            case .updateID(let id):
                state.selectedID = id
                state.unitCount = nil
                guard let set = state.selectedSet else {
                    return .task { .idUpdated }
                }
                state.unitCount = try! cd.countUnits(in: set)
                return .task { .idUpdated }
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
                        Text(vs.pickerDefaultText)
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

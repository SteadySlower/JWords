//
//  SettingSideBar.swift
//  JWords
//
//  Created by JW Moon on 2023/04/15.
//


import SwiftUI
import ComposableArchitecture

enum StudyMode: Hashable, CaseIterable, Equatable {
    case all, excludeSuccess, onlyFail
    
    var pickerText: String {
        switch self {
        case .all: return "전부"
        case .excludeSuccess: return "O제외"
        case .onlyFail: return "X만"
        }
    }
}

enum StudyViewMode: Hashable, Equatable {
    case normal
    case selection
    case edit
}

struct StudySetting: ReducerProtocol {
    struct State: Equatable {
        var studyMode: StudyMode = .all
        var frontType: FrontType
        var studyViewMode: StudyViewMode = .normal
        
        init(frontMode: FrontType = .kanji) {
            self.frontType = frontMode
        }
    }
    
    enum Action: Equatable {
        case setStudyMode(StudyMode)
        case setFrontType(FrontType)
        case setStudyViewMode(StudyViewMode)
        case wordBookEditButtonTapped
        case wordAddButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setFrontType(let type):
                state.frontType = type
                return .none
            case .setStudyMode(let mode):
                state.studyMode = mode
                return .none
            case .setStudyViewMode(let mode):
                state.studyViewMode = mode
                return .none
            case .wordBookEditButtonTapped:
                return .none
            case .wordAddButtonTapped:
                return .none
            }
        }
    }
}

struct SettingSideBar: View {
    
    let store: StoreOf<StudySetting>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Spacer()
                Picker("", selection: vs.binding(
                    get: \.studyMode,
                    send: StudySetting.Action.setStudyMode)
                ) {
                    ForEach(StudyMode.allCases, id: \.self) {
                        Text($0.pickerText)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                Picker("", selection: vs.binding(
                    get: \.frontType,
                    send: StudySetting.Action.setFrontType)
                ) {
                    ForEach(FrontType.allCases, id: \.self) {
                        Text($0.pickerText)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                Picker("모드", selection: vs.binding(
                    get: \.studyViewMode,
                    send: StudySetting.Action.setStudyViewMode)
                ) {
                    Text("학습")
                        .tag(StudyViewMode.normal)
                    Text("선택")
                        .tag(StudyViewMode.selection)
                    Text("수정")
                        .tag(StudyViewMode.edit)
                }
                .pickerStyle(.segmented)
                .padding()
                Button("단어장 수정") {
                    vs.send(.wordBookEditButtonTapped)
                }
                .padding()
                Button("단어 추가") {
                    vs.send(.wordAddButtonTapped)
                }
                .padding()
                Spacer()
            }
        }
    }
}

struct SettingSideBar_Previews: PreviewProvider {
    
    static var previews: some View {
        SettingSideBar(
            store: Store(
                initialState: StudySetting.State(frontMode: .kanji),
                reducer: StudySetting()._printChanges()
            )
        )
    }
}


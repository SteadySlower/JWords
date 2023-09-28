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
    case delete
}

struct StudySetting: ReducerProtocol {
    struct State: Equatable {
        let set: StudySet?
        let selectableViewModes: [StudyViewMode]
        var studyMode: StudyMode = .all
        var frontType: FrontType
        var studyViewMode: StudyViewMode = .normal
        
        init(
            set: StudySet? = nil,
            frontType: FrontType = .kanji
        ) {
            self.set = set
            self.frontType = frontType
            if set != nil {
                selectableViewModes = [.normal, .selection, .edit, .delete]
            } else {
                selectableViewModes = [.normal, .edit]
            }
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
            VStack(spacing: 10) {
                if vs.set != nil {
                    VStack(spacing: 10) {
                        RectangleButton(
                            image: Image(systemName: "rectangle.and.pencil.and.ellipsis"),
                            title: "단어장 수정",
                            isVertical: false
                        ) { vs.send(.wordBookEditButtonTapped) }
                        RectangleButton(
                            image: Image(systemName: "plus"),
                            title: "단어추가",
                            isVertical: false
                        ) { vs.send(.wordAddButtonTapped) }
                    }
                    .padding()
                }
                VStack(spacing: 5) {
                    Text("단어 필터")
                        .leadingAlignment()
                    Picker("", selection: vs.binding(
                        get: \.studyMode,
                        send: StudySetting.Action.setStudyMode)
                    ) {
                        ForEach(StudyMode.allCases, id: \.self) {
                            Text($0.pickerText)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                VStack(spacing: 5) {
                    Text("앞면 유형")
                        .leadingAlignment()
                    Picker("", selection: vs.binding(
                        get: \.frontType,
                        send: StudySetting.Action.setFrontType)
                    ) {
                        ForEach(FrontType.allCases, id: \.self) {
                            Text($0.pickerText)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                VStack(spacing: 5) {
                    Text("단어 리스트 모드")
                        .leadingAlignment()
                    Picker("", selection: vs.binding(
                        get: \.studyViewMode,
                        send: StudySetting.Action.setStudyViewMode)
                    ) {
                        Text("학습")
                            .tag(StudyViewMode.normal)
                        Text("이동")
                            .tag(StudyViewMode.selection)
                        Text("수정")
                            .tag(StudyViewMode.edit)
                        Text("삭제")
                            .tag(StudyViewMode.delete)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                Spacer()
            }
            .padding(.top, 100)
        }
    }
}

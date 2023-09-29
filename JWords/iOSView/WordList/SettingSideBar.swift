//
//  SettingSideBar.swift
//  JWords
//
//  Created by JW Moon on 2023/04/15.
//


import SwiftUI
import ComposableArchitecture

enum UnitFilter: Hashable, CaseIterable, Equatable {
    case all, excludeSuccess, onlyFail
    
    var pickerText: String {
        switch self {
        case .all: return "전부"
        case .excludeSuccess: return "O제외"
        case .onlyFail: return "X만"
        }
    }
}

struct StudySetting: ReducerProtocol {
    struct State: Equatable {
        let set: StudySet?
        let selectableListType: [ListType]
        var filter: UnitFilter = .all
        var frontType: FrontType
        var listType: ListType = .study
        
        init(
            set: StudySet? = nil,
            frontType: FrontType = .kanji
        ) {
            self.set = set
            self.frontType = frontType
            if set != nil {
                selectableListType = [.study, .select, .edit, .delete]
            } else {
                selectableListType = [.study, .edit]
            }
        }
    }
    
    enum Action: Equatable {
        case setFilter(UnitFilter)
        case setFrontType(FrontType)
        case setListType(ListType)
        case wordBookEditButtonTapped
        case wordAddButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setFrontType(let type):
                state.frontType = type
                return .none
            case .setFilter(let filter):
                state.filter = filter
                return .none
            case .setListType(let type):
                state.listType = type
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
                        get: \.filter,
                        send: StudySetting.Action.setFilter)
                    ) {
                        ForEach(UnitFilter.allCases, id: \.self) {
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
                        get: \.listType,
                        send: StudySetting.Action.setListType)
                    ) {
                        Text("학습")
                            .tag(ListType.study)
                        Text("이동")
                            .tag(ListType.select)
                        Text("수정")
                            .tag(ListType.edit)
                        Text("삭제")
                            .tag(ListType.delete)
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

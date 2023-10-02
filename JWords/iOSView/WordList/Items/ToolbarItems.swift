//
//  ToolbarItems.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct StudyTools: ReducerProtocol {
    
    enum ToolButton: Hashable {
        case book, shuffle, setting
        
        var imageName: String {
            switch self {
            case .book:
                return "book.closed"
            case .shuffle:
                return "shuffle"
            case .setting:
                return "gearshape"
            }
        }
        
        var action: StudyTools.Action {
            switch self {
            case .book:
                return .book
            case .shuffle:
                return .shuffle
            case .setting:
                return .setting
            }
        }
    }
    
    struct State: Equatable {
        let activeButtons: [ToolButton]
    }
    
    enum Action: Equatable {
        case book
        case shuffle
        case setting
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
}

struct StudyToolBarButtons: View {
    
    let store: StoreOf<StudyTools>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            HStack {
                ForEach(vs.activeButtons, id: \.self) { button in
                    Button {
                        vs.send(button.action)
                    } label: {
                        Image(systemName: button.imageName)
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
}

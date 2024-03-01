//
//  ToolbarItems.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct StudyTools {
    
    enum ToolButton: Hashable {
        case set, shuffle, setting
        
        var imageName: String {
            switch self {
            case .set:
                return "book.closed"
            case .shuffle:
                return "shuffle"
            case .setting:
                return "gearshape"
            }
        }
        
        var action: StudyTools.Action {
            switch self {
            case .set:
                return .set
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
        case set
        case shuffle
        case setting
    }
    
    var body: some Reducer<State, Action> {
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

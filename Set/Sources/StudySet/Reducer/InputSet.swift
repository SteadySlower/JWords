//
//  InputSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI
import Model
import CommonUI

@Reducer
public struct InputSet {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public var title: String
        public var frontType: FrontType
        
        public init(
            title: String = "",
            frontType: FrontType = .kanji
        ) {
            self.title = title
            self.frontType = frontType
        }
    }
    
    public enum Action: Equatable {
        case setTitle(String)
        case setFrontType(FrontType)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setTitle(let title):
                state.title = title
                return .none
            case .setFrontType(let frontType):
                state.frontType = frontType
                return .none
            }
        }
    }
    
}


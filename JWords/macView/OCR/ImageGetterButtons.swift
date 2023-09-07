//
//  ImageGetterButtons.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import SwiftUI
import ComposableArchitecture

struct GetImageForOCR: ReducerProtocol {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        case clipBoardButtonTapped
        case cameraButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { _, _ in return .none }
    }
    
}


struct ImageGetterButtons: View {
    
    let store: StoreOf<GetImageForOCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            HStack {
                Spacer()
                Button {
                    vs.send(.clipBoardButtonTapped)
                } label: {
                    VStack {
                        Image(systemName: "list.clipboard")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("클립보드에서\n이미지 가져오기")
                    }
                    .padding(8)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                        )
                }
                Spacer()
                Button {
                    vs.send(.cameraButtonTapped)
                } label: {
                    VStack {
                        Spacer()
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("카메라로 촬영하기")
                        Spacer()
                    }
                    .padding(8)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                    )
                }
                Spacer()
            }
        }
    }
}

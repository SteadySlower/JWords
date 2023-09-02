//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import SwiftUI
import ComposableArchitecture

struct OCR: ReducerProtocol {
    struct State: Equatable {
        var image: InputImageType?
        var ocrResult: String = ""
    }
    
    enum Action: Equatable {
        case buttonTapped
        case imageTapped
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                state.image = pasteBoardClient.fetchImage()
                return .none
            case .imageTapped:
                state.image = nil
                return .none
            }
        }
    }

}


struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                if let image = vs.image {
                    Group {
                        #if os(iOS)
                        Image(uiImage: image).resizable()
                        #elseif os(macOS)
                        Image(nsImage: image).resizable()
                        #endif
                    }
                    .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                    .onTapGesture { vs.send(.imageTapped) }
                } else {
                    Button {
                        vs.send(.buttonTapped)
                    } label: {
                        Text("뜻 이미지")
                    }
                }
                Text("OCR 결과: \(vs.ocrResult)")
            }
        }
    }
}


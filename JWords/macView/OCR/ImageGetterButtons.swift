//
//  ImageGetterButtons.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import SwiftUI
import ComposableArchitecture

private enum ImageSource {
    case clipboard, camera
    
    var imageName: String {
        switch self {
        case.clipboard: return "list.clipboard"
        case .camera: return "camera"
        }
    }
    
    var buttonText: String {
        switch self {
        case.clipboard: return "클립보드에서\n이미지 가져오기"
        case .camera: return "카메라로 촬영하기"
        }
    }
}

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
                button(for: .clipboard) {
                    vs.send(.clipBoardButtonTapped)
                }
                Spacer()
                button(for: .camera) {
                    vs.send(.cameraButtonTapped)
                }
                Spacer()
            }
        }
    }
}

// MARK: SubViews

extension ImageGetterButtons {
    
    private func button(for imageSource: ImageSource, _ onTapped: @escaping () -> Void) -> some View {
        RectangleButton(
            image: Image(systemName: imageSource.imageName),
            title: imageSource.buttonText,
            onTapped: onTapped)
    }
    
}
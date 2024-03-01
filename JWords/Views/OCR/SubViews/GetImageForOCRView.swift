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

@Reducer
struct GetImageForOCR {
    struct State: Equatable {
        var showCameraScanner: Bool = false
    }
    
    enum Action: Equatable {
        case clipBoardButtonTapped
        case cameraButtonTapped
        case showCameraScanner(Bool)
        case cameraImageSelected(InputImageType)
        case imageFetched(InputImageType)
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    @Dependency(\.utilClient) var utilClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .clipBoardButtonTapped:
                guard
                    let fetchedImage = pasteBoardClient.fetchImage(),
                    let resized = utilClient.resizeImage(fetchedImage)
                else { return .none }
                return .send(.imageFetched(resized))
            case .cameraButtonTapped:
                state.showCameraScanner = true
                return .none
            case .showCameraScanner(let show):
                state.showCameraScanner = show
                return .none
            case .cameraImageSelected(let image):
                guard let resized = utilClient.resizeImage(image) else { return .none }
                return .send(.imageFetched(resized))
            default: return .none
            }
        }
    }
}

struct GetImageForOCRView: View {
    
    let store: StoreOf<GetImageForOCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                ScanGuide()
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
            #if os(iOS)
            .sheet(isPresented: vs.binding(
                get: \.showCameraScanner,
                send: GetImageForOCR.Action.showCameraScanner)
            ) {
                CameraScanner { vs.send(.cameraImageSelected($0)) }
            }
            #endif
        }
    }
}

// MARK: SubViews

extension GetImageForOCRView {
    
    private func button(for imageSource: ImageSource, _ onTapped: @escaping () -> Void) -> some View {
        RectangleButton(
            image: Image(systemName: imageSource.imageName),
            title: imageSource.buttonText,
            onTapped: onTapped)
    }
    
}

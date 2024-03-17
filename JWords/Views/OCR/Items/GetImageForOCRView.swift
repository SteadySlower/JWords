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
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        case cameraScanner(ScanWithCamera)
    }
    
    enum Action: Equatable {
        case getImageFromClipboard
        case getImageFromCamera
        case imageFetched(InputImageType)
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    @Dependency(\.utilClient) var utilClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImageFromClipboard:
                guard
                    let fetchedImage = pasteBoardClient.fetchImage(),
                    let resized = utilClient.resizeImage(fetchedImage)
                else { return .none }
                return .send(.imageFetched(resized))
            case .getImageFromCamera:
                state.destination = .cameraScanner(.init())
                return .none
            case .destination(.presented(.cameraScanner(.imageSelected(let image)))):
                guard let resized = utilClient.resizeImage(image) else { return .none }
                return .send(.imageFetched(resized))
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct GetImageForOCRView: View {
    
    @Bindable var store: StoreOf<GetImageForOCR>
    
    var body: some View {
        VStack {
            ScanGuide()
            HStack {
                Spacer()
                button(for: .clipboard) {
                    store.send(.getImageFromClipboard)
                }
                Spacer()
                button(for: .camera) {
                    store.send(.getImageFromCamera)
                }
                Spacer()
            }
        }
        #if os(iOS)
        .sheet(item: $store.scope(state: \.destination?.cameraScanner, action: \.destination.cameraScanner)) {
            CameraScanner(store: $0)
        }
        #endif
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

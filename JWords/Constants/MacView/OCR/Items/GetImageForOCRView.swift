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
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .clipBoardButtonTapped:
                guard
                    let fetchedImage = pasteBoardClient.fetchImage(),
                    let resized = resizeImage(fetchedImage)
                else { return .none }
                return .task { .imageFetched(resized) }
            case .cameraButtonTapped:
                state.showCameraScanner = true
                return .none
            case .showCameraScanner(let show):
                state.showCameraScanner = show
                return .none
            case .cameraImageSelected(let image):
                guard let resized = resizeImage(image) else { return .none }
                return .task { .imageFetched(resized) }
            default: return .none
            }
        }
    }
    
}

// TODO: move this somewhere proper

fileprivate func resizeImage(_ image: InputImageType) -> InputImageType? {
    // Calculate Size
    let newWidth = Constants.Size.deviceWidth - 10
    let newHeight = newWidth * (image.size.height / image.size.width)
    let newSize = CGSize(width: newWidth, height: newHeight)
    
    // If image is small enough, return original one
    if image.size.width < newWidth {
        return image
    }
    
    #if os(iOS)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
    #elseif os(macOS)
     let newImage = NSImage(size: newSize)

     newImage.lockFocus()

     NSGraphicsContext.current?.imageInterpolation = .high

     image.draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight),
                from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                operation: .sourceOver,
                fraction: 1.0)

     newImage.unlockFocus()

     return newImage
     #endif
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

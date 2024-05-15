//
//  ImageGetterButtons.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import SwiftUI
import ComposableArchitecture
import Model
import PasteBoardClient
import UtilClient
import PhotosUI

private enum ImageSource {
    case clipboard, camera, photoLibrary
    
    var imageName: String {
        switch self {
        case.clipboard: return "list.clipboard"
        case .camera: return "camera"
        case .photoLibrary: return "photo.stack"
        }
    }
    
    var buttonText: String {
        switch self {
        case.clipboard: return "클립보드"
        case .camera: return "카메라"
        case .photoLibrary: return "photo_library_button_text"
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
    
    @Dependency(PasteBoardClient.self) var pasteBoardClient
    @Dependency(UtilClient.self) var utilClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImageFromClipboard:
                guard let fetchedImage = pasteBoardClient.fetchImage() else { return .none }
                return .send(.imageFetched(fetchedImage))
            case .getImageFromCamera:
                state.destination = .cameraScanner(.init())
                return .none
            case .destination(.presented(.cameraScanner(.imageSelected(let image)))):
                return .send(.imageFetched(image))
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct GetImageForOCRView: View {
    
    @Bindable var store: StoreOf<GetImageForOCR>
    @State private var selectedItem: PhotosPickerItem?
    
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
                photoPicker
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
    
    private var photoPicker: some View {
        PhotosPicker(selection: $selectedItem) {
            VStack {
                Spacer()
                Image(systemName: ImageSource.photoLibrary.imageName)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(LocalizedStringKey(ImageSource.photoLibrary.buttonText))
                    .fixedSize()
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
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                    let image = UIImage(data: data) 
                {
                    store.send(.imageFetched(image))
                }
            }
        }
    }
    
}

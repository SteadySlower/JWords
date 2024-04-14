//
//  CameraScanner.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import SwiftUI

#if os(iOS)
import UIKit
import ComposableArchitecture
import Model

@Reducer
struct ScanWithCamera {
    struct State: Equatable {}
    
    enum Action: Equatable {
        case imageSelected(InputImageType)
        case cancel
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .cancel:
                return .run { _ in await self.dismiss() }
            default: break
            }
            return .none
        }
    }
}

struct CameraScanner: UIViewControllerRepresentable {
    
    let store: StoreOf<ScanWithCamera>

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraScanner

        init(_ parent: CameraScanner) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.store.send(.imageSelected(uiImage))
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.store.send(.cancel)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraScanner>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .rear
        imagePicker.cameraCaptureMode = .photo
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CameraScanner>) {
    }
}
#elseif os(macOS)

#endif



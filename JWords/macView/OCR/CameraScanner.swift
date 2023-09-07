//
//  CameraScanner.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import UIKit
import SwiftUI

struct CameraScanner: UIViewControllerRepresentable {
    private let imageSelected: (InputImageType) -> Void
    @Environment(\.dismiss) var dismiss
    
    init(_ imageSelected: @escaping (InputImageType) -> Void) {
        self.imageSelected = imageSelected
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraScanner

        init(_ parent: CameraScanner) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.imageSelected(uiImage)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
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

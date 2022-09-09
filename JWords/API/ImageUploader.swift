//
//  ImageUploader.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/28.
//

import Foundation
import FirebaseStorage

protocol ImageUploader {
    func uploadImage(image: InputImageType, group: DispatchGroup, completionHandler: @escaping (String) -> Void)
}

final class FirebaseIU: ImageUploader {
    // Storage singleton
    private lazy var store: Storage = {
        Storage.storage()
    }()
    
    // Image Compressor
    let ic: ImageCompressor
    
    init(imageCompressor: ImageCompressor) {
        self.ic = imageCompressor
    }
    
    // SwiftUI의 Image는 아직 jpeg으로 압축할 수 없음. (UIImage 필요함)
    func uploadImage(image: InputImageType, group: DispatchGroup, completionHandler: @escaping (String) -> Void) {
        group.enter()
        // 이미지 압축하기
        let jpegData = ic.compressImageToJPEG(image: image)

        // 이미지 경로 정하기
        let ref = store.reference(withPath: "/card_images/\(NSUUID().uuidString)")
        
        // 이미지 업로드
        ref.putData(jpegData, metadata: nil) { _, error in
            if let error = error {
                print("디버그: 이미지 업로드 실패 \(error.localizedDescription)")
                return
            }
            
            // 이미지 업로드 완료되면 ref의 url을 받아서 completion handler에 전달
            ref.downloadURL { url, _ in
                guard let imageURL = url?.absoluteString else { return }
                completionHandler(imageURL)
                group.leave()
            }
        }
    }
}

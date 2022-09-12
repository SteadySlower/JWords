//
//  ImageUploader.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/28.
//

import Foundation
import FirebaseStorage

protocol ImageUploader {
    func uploadImage(image: InputImageType, group: DispatchGroup, completionHandler: @escaping (String?, Error?) -> Void)
}

final class FirebaseIU: ImageUploader {
    // Storage singleton
        // lazy var를 사용한 이유는 FirebaseApp.configure()가 실행되고 나서 Firebase 객체를 init해야 하기 때문.
    private lazy var store: Storage = {
        Storage.storage()
    }()
    
    // Image Compressor
    let ic: ImageCompressor
    
    init(imageCompressor: ImageCompressor) {
        self.ic = imageCompressor
    }
    
    // SwiftUI의 Image는 아직 jpeg으로 압축할 수 없음. (UIImage 필요함)
    func uploadImage(image: InputImageType, group: DispatchGroup, completionHandler: @escaping (String?, Error?) -> Void) {
        group.enter()
        
        // 이미지 압축하기
        var jpegData: Data
        
        do {
            jpegData = try ic.compressImageToJPEG(image: image)
        } catch let error {
            completionHandler(nil, error)
            group.leave()
            return
        }

        // 이미지 경로 정하기
        let ref = store.reference(withPath: "/card_images/\(NSUUID().uuidString)")
        
        // 이미지 업로드
        ref.putData(jpegData, metadata: nil) { _, error in
            if let error = error {
                print("이미지 업로드 실패 \(error.localizedDescription)")
                let appError = AppError.ImageUploader.failToUploadImage
                completionHandler(nil, appError)
                group.leave()
                return
            }
            
            // 이미지 업로드 완료되면 ref의 url을 받아서 completion handler에 전달
            ref.downloadURL { url, error in
                if let error = error {
                    print("이미지 URL 다운로드 실패 \(error.localizedDescription)")
                    let appError = AppError.ImageUploader.failToDownloadImageURL
                    completionHandler(nil, appError)
                    group.leave()
                    return
                }
                guard let imageURL = url?.absoluteString else {
                    print("이미지 URL nil")
                    let appError = AppError.ImageUploader.imageURLNil
                    completionHandler(nil, appError)
                    group.leave()
                    return
                }
                completionHandler(imageURL, nil)
                group.leave()
            }
        }
    }
}

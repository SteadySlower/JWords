//
//  CKImageUploader.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/23.
//

import CloudKit

class CKImageUploader {
    
    static let shared = CKImageUploader()
    
    let db = CKContainer(identifier: "iCloud.JWords_iCloud").privateCloudDatabase
    
    func saveImage(data: Data) async throws -> String {
        let id = "image_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        let imageRecordID = CKRecord.ID(recordName: id)
        let imageRecord = CKRecord(recordType: "Image", recordID: imageRecordID)
        let imageAsset = CKAsset(fileURL: getFileURL(of: id))
        guard let fileURL = imageAsset.fileURL else {
            throw AppError.cloudKit
        }
        
        try data.write(to: fileURL)

        imageRecord["image"] = imageAsset
        
        return try await withCheckedThrowingContinuation { continuation in
            db.save(imageRecord) { (record, error) in
                if let error = error {
                    print("디버그: \(error)")
                    continuation.resume(with: .failure(AppError.cloudKit))
                } else {
                    continuation.resume(with: .success(id))
                }
            }
        }
    }
    
    func fetchImage(id: String) async throws -> Data {
        let imageRecordID = CKRecord.ID(recordName: id)
        
        return try await withCheckedThrowingContinuation { continuation in
            db.fetch(withRecordID: imageRecordID) { (record, error) in
                if let error = error {
                    print("디버그: \(error)")
                    continuation.resume(with: .failure(AppError.cloudKit))
                } else if let record = record,
                          let asset = record["image"] as? CKAsset,
                          let fileURL = asset.fileURL,
                          let data = try? Data(contentsOf: fileURL) {
                    continuation.resume(with: .success(data))
                } else {
                    continuation.resume(with: .failure(AppError.cloudKit))
                }
            }
        }
    }
    
    private func getFileURL(of id: String) -> URL {
        let directory = NSTemporaryDirectory()
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(id)
        return fileURL
    }
    
}

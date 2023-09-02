//
//  OCRClient.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import Foundation
import Vision
import Cocoa

class OCRClient {
    
    static let shared = OCRClient()
    
    private func ocr(from cgImage: CGImage, completionHandler: @escaping ([String], AppError?) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                completionHandler([], AppError.ocr)
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            completionHandler(recognizedStrings, nil)
            
        }
        
        request.recognitionLanguages = ["ja"]

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func ocr(from image: InputImageType) async throws -> [String] {
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("디버그 cgImage 만들기 실패")
            throw AppError.ocr
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            ocr(from: cgImage) { strings, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                }
                continuation.resume(with: .success(strings))
            }
        }
    }
    
}

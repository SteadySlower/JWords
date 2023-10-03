//
//  OCRService.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Vision
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

enum OCRLang {
    case korean, japanese
    
    var recognitionLanguage: String {
        switch self {
        case .korean:
            return "ko"
        case .japanese:
            return "ja"
        }
    }
}

struct OCRResult: Identifiable, Equatable {
    let id: UUID = .init()
    let string: String
    let position: CGRect
    
    init(string: String, position: CGRect) {
        self.string = string
        self.position = position
    }
    
    static let empty: Self = .init(string: "", position: .zero)
}

final class OCRService {
    
    static let shared = OCRService()
    
    private func ocr(from image: InputImageType, lang: OCRLang, completionHandler: @escaping ([OCRResult], AppError?) -> Void) {
        
        #if os(iOS)
        guard let cgImage = image.cgImage else {
            print("디버그 cgImage 만들기 실패")
            completionHandler([], .ocr)
            return
        }
        #elseif os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("디버그 cgImage 만들기 실패")
            completionHandler([], .ocr)
            return
        }
        #endif
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                completionHandler([], .ocr)
                return
            }
            
            let result: [OCRResult] = observations.compactMap { observation in
                guard let candidate = observation.topCandidates(1).first else { return OCRResult.empty }
                
                let string = candidate.string
                
                let stringRange = candidate.string.startIndex..<candidate.string.endIndex
                let boxObservation = try? candidate.boundingBox(for: stringRange)
                
                let position = boxObservation?.boundingBox ?? .zero
                
                return OCRResult(string: string, position: position)
            }
            
            completionHandler(result, nil)
            
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = [lang.recognitionLanguage]

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func ocr(from image: InputImageType, lang: OCRLang) async throws -> [OCRResult] {
        return try await withCheckedThrowingContinuation { continuation in
            ocr(from: image, lang: lang) { rects, error in
                if let error = error {
                    continuation.resume(with: .failure(error))
                }
                continuation.resume(with: .success(rects))
            }
        }
    }
    
}

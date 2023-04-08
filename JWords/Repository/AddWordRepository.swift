//
//  AddWordRepository.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Foundation
import Combine

class AddWordRepository: Repository {
    
    private let wordService: WordService
    private let pasteBoardService: PasteBoardService
    
    init(wordService: WordService = ServiceManager.shared.wordService,
         pasteBoardService: PasteBoardService = ServiceManager.shared.pasteBoardService) {
        self.wordService = wordService
        self.pasteBoardService = pasteBoardService
        super.init()
    }
    
    override func clear() {
        super.clear()
        // TODO: add properties to clear
    }

    @Published private(set) var wordBook: WordBook?
    @Published private(set) var meaningImage: InputImageType?
    @Published private(set) var ganaImage: InputImageType?
    @Published private(set) var kanjiImage: InputImageType?
    
    func updateWordBook(_ wordBook: WordBook?) {
        self.wordBook = wordBook
    }
    
    func updateImage(_ type: InputType) {
        switch type {
        case .meaning:
            self.meaningImage = pasteBoardService.fetchImage()
        case .kanji:
            self.kanjiImage = pasteBoardService.fetchImage()
        case .gana:
            self.ganaImage = pasteBoardService.fetchImage()
        }
    }
    
    func clearImage(_ type: InputType) {
        switch type {
        case .meaning:
            self.meaningImage = nil
        case .kanji:
            self.kanjiImage = nil
        case .gana:
            self.ganaImage = nil
        }
    }
    
}



//
//  AddWordRepository.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Foundation
import Combine

protocol AddWordRepository: BaseRepository {
    var wordBook: AnyPublisher<WordBook?, Never> { get }
    var meaningImage: AnyPublisher<InputImageType?, Never> { get }
    var ganaImage: AnyPublisher<InputImageType?, Never> { get }
    var kanjiImage: AnyPublisher<InputImageType?, Never> { get }
    
    func updateWordBook(_ wordBook: WordBook?)
    func updateImage(_ type: InputType)
    func clearImage(_ type: InputType)
}

class AddWordRepositoryImpl: Repository, AddWordRepository {
    
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

    @Published private(set) var _wordBook: WordBook?
    var wordBook: AnyPublisher<WordBook?, Never> { $_wordBook.eraseToAnyPublisher() }
    
    @Published private(set) var _meaningImage: InputImageType?
    var meaningImage: AnyPublisher<InputImageType?, Never> { $_meaningImage.eraseToAnyPublisher() }
    
    @Published private(set) var _ganaImage: InputImageType?
    var ganaImage: AnyPublisher<InputImageType?, Never> { $_ganaImage.eraseToAnyPublisher() }
    
    @Published private(set) var _kanjiImage: InputImageType?
    var kanjiImage: AnyPublisher<InputImageType?, Never> { $_kanjiImage.eraseToAnyPublisher() }
    
    func updateWordBook(_ wordBook: WordBook?) {
        self._wordBook = wordBook
    }
    
    func updateImage(_ type: InputType) {
        switch type {
        case .meaning:
            self._meaningImage = pasteBoardService.fetchImage()
        case .kanji:
            self._kanjiImage = pasteBoardService.fetchImage()
        case .gana:
            self._ganaImage = pasteBoardService.fetchImage()
        }
    }
    
    func clearImage(_ type: InputType) {
        switch type {
        case .meaning:
            self._meaningImage = nil
        case .kanji:
            self._kanjiImage = nil
        case .gana:
            self._ganaImage = nil
        }
    }
    
}



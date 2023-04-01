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
    func updateMeaningImage()
    func updateGanaImage()
    func updateKanjiImage()
    func clearMeaningImage()
    func clearGanaImage()
    func clearKanjiImage()
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
    
    func updateMeaningImage() {
        self._meaningImage = pasteBoardService.fetchImage()
    }
    
    func updateGanaImage() {
        self._ganaImage = pasteBoardService.fetchImage()
    }

    func updateKanjiImage() {
        self._kanjiImage = pasteBoardService.fetchImage()
    }

    func clearMeaningImage() {
        self._meaningImage = nil
    }
    
    func clearGanaImage() {
        self._ganaImage = nil
    }
    
    func clearKanjiImage() {
        self._kanjiImage = nil
    }
    
}



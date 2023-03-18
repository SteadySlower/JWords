//
//  AddWordRepository.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Foundation
import Combine

protocol AddWordRepository {
    var wordBook: AnyPublisher<WordBook?, Never> { get }
    var meaningImage: AnyPublisher<InputImageType?, Never> { get }
    var ganaImage: AnyPublisher<InputImageType?, Never> { get }
    var kanjiImage: AnyPublisher<InputImageType?, Never> { get }
    
    func updateWordBook(_ wordBook: WordBook?)
    func updateMeaningImage(_ image: InputImageType?)
    func updateGanaImage(_ image: InputImageType?)
    func updateKanjiImage(_ image: InputImageType?)
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
    var kanjiImage: AnyPublisher<InputImageType?, Never> { $_ganaImage.eraseToAnyPublisher() }
    
    func updateWordBook(_ wordBook: WordBook?) {
        self._wordBook = wordBook
    }
    
    func updateMeaningImage(_ image: InputImageType?) {
        self._meaningImage = image
    }
    
    func updateGanaImage(_ image: InputImageType?) {
        self._ganaImage = image
    }

    func updateKanjiImage(_ image: InputImageType?) {
        self._kanjiImage = image
    }

    
    
}



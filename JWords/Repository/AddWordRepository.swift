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
    var meaningImage: AnyPublisher<WordBook?, Never> { get }
    var ganaImage: AnyPublisher<WordBook?, Never> { get }
    var kanjiImage: AnyPublisher<WordBook?, Never> { get }
}

class AddWordRepositoryImpl: Repository, AddWordRepository {
    
    private let wordService: WordService
    
    init(wordService: WordService = ServiceManager.shared.wordService) {
        self.wordService = wordService
        super.init()
    }
    
    override func clear() {
        super.clear()
        // TODO: add properties to clear
    }

    @Published private(set) var _wordBook: WordBook?
    var wordBook: AnyPublisher<WordBook?, Never> { $_wordBook.eraseToAnyPublisher() }
    
    @Published private(set) var _meaningImage: InputImageType?
    var meaningImage: AnyPublisher<WordBook?, Never> { $_wordBook.eraseToAnyPublisher() }
    
    @Published private(set) var _ganaImage: InputImageType?
    var ganaImage: AnyPublisher<WordBook?, Never> { $_wordBook.eraseToAnyPublisher() }
    
    @Published private(set) var _kanjiImage: InputImageType?
    var kanjiImage: AnyPublisher<WordBook?, Never> { $_wordBook.eraseToAnyPublisher() }
    
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



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
    
    // states

    @Published private(set) var wordBook: WordBook?
    @Published private(set) var meaningText: String = ""
    @Published private(set) var ganaText: String = ""
    @Published private(set) var kanjiText: String = ""
    @Published private(set) var meaningImage: InputImageType?
    @Published private(set) var ganaImage: InputImageType?
    @Published private(set) var kanjiImage: InputImageType?
    @Published private(set) var autoConvertMode: Bool = true
    
    // public methods
    
    func updateWordBook(_ wordBook: WordBook?) {
        self.wordBook = wordBook
    }
    
    func updateText(_ type: InputType, _ text: String) {
        switch type {
        case .meaning:
            meaningText = text
        case .kanji:
            kanjiText = text
            autoConvert(text)
        case .gana:
            ganaText = text
            trimPastedText(text)
        }
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
    
    func updateAutoConvertMode(_ autoConvertMode: Bool) {
        self.autoConvertMode = autoConvertMode
    }
    
    // private methods
    
    // 한자 -> 가나 auto convert
    private func autoConvert(_ kanji: String) {
        if !autoConvertMode { return }
        ganaText = kanji.hiragana
    }
    
    // 네이버 사전에서 복사-붙여넣기할 때 "히라가나 [한자]" 형태로 된 텍스트 가나-한자로 구분
    private func trimPastedText(_ text: String) {
        guard text.contains("[") else { return }
        var strings = text.split(separator: " ")
        guard strings.count >= 2 else { return }
        strings[0] = strings[0].filter { $0 != "-" } // 장음표시 제거
        strings[1] = strings[1].filter { !["[", "]"].contains($0) }
        ganaText = String(strings[0])
        kanjiText = String(strings[1])
    }
    
}



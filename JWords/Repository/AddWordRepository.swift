//
//  AddWordRepository.swift
//  JWords
//
//  Created by JW Moon on 2023/03/18.
//

import Foundation
import Combine

class AddWordRepository: Repository {
    
    private let wordBookService: WordBookService
    private let wordService: WordService
    private let sampleService: SampleService
    private let pasteBoardService: PasteBoardService
    
    init(wordBookService: WordBookService = ServiceManager.shared.wordBookService,
        wordService: WordService = ServiceManager.shared.wordService,
         sampleService: SampleService = ServiceManager.shared.sampleService,
         pasteBoardService: PasteBoardService = ServiceManager.shared.pasteBoardService) {
        self.wordBookService = wordBookService
        self.wordService = wordService
        self.sampleService = sampleService
        self.pasteBoardService = pasteBoardService
        super.init()
    }
    
    override func clear() {
        super.clear()
        // TODO: add properties to clear
    }
    
    // states

    @Published private(set) var wordBook: WordBook?
    @Published private(set) var wordCount: Int?
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
        print("type: \(type) text: \(text)")
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
    
    func updateText(with sample: Sample) {
        meaningText = sample.meaningText
        ganaText = sample.ganaText
        kanjiText = sample.kanjiText
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
    
    func saveWord(_ sample: Sample?) {
        updateIsLoading(true)
        
        guard let wordBook = wordBook else {
            print("디버그: 선택된 단어장이 없어서 저장할 수 없음")
            updateIsLoading(false)
            return
        }
        
        let wordInput = makeWordInput(id: wordBook.id)
        
        if let sample = sample {
            handleSample(wordInput: wordInput, sample: sample)
        }
        
        wordService.saveWord(wordInput: wordInput) { error in
            // TODO: handle error
            if let error = error { self.onError(error) }
            self.updateIsLoading(false)
        }
        
    }
    
    // private methods
    
    private func countWords() {
        guard let wordBook = wordBook else {
            wordCount = nil
            return
        }
        wordBookService.countWords(in: wordBook) { count, error in
            if let error = error { self.onError(error); return }
            if let count = count { self.wordCount = count }
        }
    }
    
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
    
    // 입력하기 전에 좌우 공백 제거
    private func trimTexts() {
        meaningText = meaningText.lStrip()
        meaningText = meaningText.rStrip()
        kanjiText = kanjiText.lStrip()
        kanjiText = kanjiText.rStrip()
        ganaText = ganaText.lStrip()
        ganaText = ganaText.rStrip()
    }
    
    private func clearInputs() {
        meaningText = ""
        meaningImage = nil
        ganaText = ""
        ganaImage = nil
        kanjiText = ""
        kanjiImage = nil
    }
    
    private func makeWordInput(id: String) -> WordInput {
        trimTexts()
        let wordInput = WordInputImpl(wordBookID: id,
                                      meaningText: meaningText,
                                      meaningImage: meaningImage,
                                      ganaText: ganaText,
                                      ganaImage: ganaImage,
                                      kanjiText: kanjiText,
                                      kanjiImage: kanjiImage)
        clearInputs()
        return wordInput
    }
    
    private func handleSample(wordInput: WordInput, sample: Sample) {
        let isEqual = (sample.meaningText == wordInput.meaningText
                       && sample.ganaText == wordInput.ganaText
                       && sample.kanjiText == wordInput.kanjiText)
        if isEqual {
            sampleService.addOneToUsed(of: sample)
        } else if !wordInput.hasImage {
            sampleService.saveSample(wordInput: wordInput)
        }
    }
    
}



//
//  DataResettingScript.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/09.
//

//import Firebase
//
//class DataResettingScript {
//    // 전체 데이터를 새로 작성하는 함수 (단어장 그대로 옮기기)
//    static func resetBookData() {
//        // 기존의 단어장의 데이터를 동일하게 새로운 단어장을 만든다.
//        WordService.getWordBooks { wordBooks, _ in
//            guard let wordBooks = wordBooks else { return }
//            for wordBook in wordBooks {
//                let data: [String : Any] = [
//                    "title": wordBook.title,
//                    "timestamp": wordBook.timestamp]
//                Firestore.firestore()
//                    .collection("develop")
//                    .document("data")
//                    .collection("wordBooks")
//                    .addDocument(data: data) { _ in
//                        // 새로 생긴 단어장을 전부 fetch 해와서
//                        getNewWordBooks(wordBook: wordBook) { wordBooks in
//                            // 기존의 단어장과 이름이 일치하는 곳에 새로 단어 저장
//                            guard let oldID = wordBook.id else { return }
//                            let newId = wordBooks.first(where: { $0.title == wordBook.title })!.id!
//                            resetWordData(oldID: oldID, newID: newId)
//                        }
//                    }
//            }
//        }
//    }
    
//    // 각 단어장에서 추출한 단어들을 wordExamples로 만들어서 옮기는 과정
//    static func moveWordsToWordExamples() {
//        // 단어장 전부 가져오기
//        WordService.getWordBooks { books, error in
//            if let error = error {
//                print(error)
//                return
//            }
//            guard let books = books else {
//                print("books is nil")
//                return
//            }
//            // 모든 단어장 순환해서
//            for book in books {
//                // 단어장에 있는 단어 전부 fetch 해오기
//                WordService.getWords(wordBookID: book.id!) { words, error in
//                    if let error = error {
//                        print(error)
//                        return
//                    }
//                    guard let words = words else {
//                        print("words is nil in wordbooks \(book.id!)")
//                        return
//                    }
//                    // 모든 단어 wordExample로 만들어서 저장
//                    for word in words {
//                        saveWordExample(word)
//                    }
//                }
//            }
//
//        }
//    }
//
//    // 이미 있는 단어를 examples에 저장하는 함수
//    static func saveWordExample(_ word: Word) {
//        let data: [String : Any] = ["timestamp": Timestamp(date: Date()),
//                                    "meaningText": word.meaningText,
//                                    "meaningImageURL": word.meaningImageURL,
//                                    "ganaText": word.ganaText,
//                                    "ganaImageURL": word.ganaImageURL,
//                                    "kanjiText": word.kanjiText,
//                                    "kanjiImageURL": word.kanjiImageURL,
//                                    "used": 0]
//        Constants.Collections.examples.addDocument(data: data)
//    }
    
    // 각 단어장에서 단어들 모두 가져와서 WordExampleInput으로 바꾸는 함수
    
//    // 새로운 단어장을 모두 가져온다
//    private static func getNewWordBooks(wordBook: WordBook, completion: @escaping ([WordBook]) -> Void) {
//        Firestore.firestore()
//            .collection("develop")
//            .document("data")
//            .collection("wordBooks")
//            .getDocuments { snapshot, _ in
//                guard let documents = snapshot?.documents else { return }
//                let wordBooks = documents.compactMap({ try? $0.data(as: WordBook.self) })
//                completion(wordBooks)
//            }
//    }
    
//    // 기존 단어장의 단어장을 가져와서 새로운 단어장에 쓴다.
//    private static func resetWordData(oldID: String, newID: String) {
//        WordService.getWords(wordBookID: oldID) { words, _ in
//            guard let words = words else { return }
//            for word in words {
//                let data: [String : Any] = ["timestamp": word.timestamp,
//                                            "meaningText": word.frontText,
//                                            "meaningImageURL": word.frontImageURL,
//                                            "ganaText": word.backText,
//                                            "ganaImageURL": word.backImageURL,
//                                            "kanjiText": "",
//                                            "kanjiImageURL": "",
//                                            "studyState": word.studyState.rawValue]
//                Firestore.firestore()
//                    .collection("develop")
//                    .document("data")
//                    .collection("wordBooks")
//                    .document(newID)
//                    .collection("words")
//                    .addDocument(data: data)
//            }
//        }
//    }
    
//}

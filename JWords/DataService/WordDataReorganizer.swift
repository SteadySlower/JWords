//
//  WordDataReorganizer.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/09.
//

import Firebase

class DataResettingScript {
    // 전체 데이터를 새로 작성하는 함수
    static func resetBookData() {
        // 기존의 단어장의 데이터를 동일하게 새로운 단어장을 만든다.
        WordService.getWordBooks { wordBooks, _ in
            guard let wordBooks = wordBooks else { return }
            for wordBook in wordBooks {
                let data: [String : Any] = [
                    "title": wordBook.title,
                    "timestamp": wordBook.timestamp]
                Firestore.firestore()
                    .collection("develop")
                    .document("data")
                    .collection("wordBooks")
                    .addDocument(data: data) { _ in
                        // 새로 생긴 단어장을 전부 fetch 해와서
                        getNewWordBooks(wordBook: wordBook) { wordBooks in
                            // 기존의 단어장과 이름이 일치하는 곳에 새로 단어 저장
                            guard let oldID = wordBook.id else { return }
                            let newId = wordBooks.first(where: { $0.title == wordBook.title })!.id!
                            resetWordData(oldID: oldID, newID: newId)
                        }
                    }
            }
        }
    }
    
    // 새로운 단어장을 모두 가져온다
    private static func getNewWordBooks(wordBook: WordBook, completion: @escaping ([WordBook]) -> Void) {
        Firestore.firestore()
            .collection("develop")
            .document("data")
            .collection("wordBooks")
            .getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let wordBooks = documents.compactMap({ try? $0.data(as: WordBook.self) })
                completion(wordBooks)
            }
    }
    
    // 기존 단어장의 단어장을 가져와서 새로운 단어장에 쓴다.
    private static func resetWordData(oldID: String, newID: String) {
        WordService.getWords(wordBookID: oldID) { words, _ in
            guard let words = words else { return }
            for word in words {
                let data: [String : Any] = ["timestamp": word.timestamp,
                                            "meaningText": word.frontText,
                                            "meaningImageURL": word.frontImageURL,
                                            "ganaText": word.backText,
                                            "ganaImageURL": word.backImageURL,
                                            "kanjiText": "",
                                            "kanjiImageURL": "",
                                            "studyState": word.studyState.rawValue]
                Firestore.firestore()
                    .collection("develop")
                    .document("data")
                    .collection("wordBooks")
                    .document(newID)
                    .collection("words")
                    .addDocument(data: data)
            }
        }
    }
}

//
//  FirebaseCollections.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Firebase

extension Constants {
    enum Collections {
        static let wordBooks = Firestore.firestore().collection("books")
        static func word(_ bookID: String) -> CollectionReference { Firestore.firestore().collection("books").document(bookID).collection("words")
        }
    }
}

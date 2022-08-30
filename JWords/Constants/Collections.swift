//
//  FirebaseCollections.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Firebase

extension Constants {
    enum Collections {
        static let wordBooks =
            Firestore.firestore()
            .collection("develop")
            .document("data")
            .collection("wordBooks")
        static func word(_ bookID: String) -> CollectionReference {
            Firestore.firestore()
            .collection("develop")
            .document("data")
            .collection("wordBooks")
            .document(bookID)
            .collection("words")
        }
        static let examples =
            Firestore.firestore()
            .collection("develop")
            .document("data")
            .collection("examples")
    }
}

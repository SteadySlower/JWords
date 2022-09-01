//
//  Service.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/01.
//

// API 서비스의 싱글톤 객체들을 모아놓은 파일

import Firebase

enum Service {
    static let Firestore = FirestoreWordDB()
}

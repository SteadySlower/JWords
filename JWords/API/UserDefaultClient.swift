//
//  UserDefaultClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/08.
//

import Foundation

enum UserDefaultKey: String, CaseIterable {
    case studySets, reviewSets, reviewedSets, createdAt
}

final class UserDefaultClient {
    
    static let shared = UserDefaultClient()

    private let userDefaults = UserDefaults.standard
    
    func fetchSchedule() -> TodaySchedule {
        TodaySchedule(studyIDs: arrayOfString(for: .studySets),
                      reviewIDs: arrayOfString(for: .reviewSets),
                      reviewedIDs: arrayOfString(for: .reviewedSets),
                      createdAt: date(for: .createdAt))
    }
    
    func authSetSchedule(sets: [StudySet]) {
        let studySets = sets.filter { $0.schedule == .study }.map { $0.id }
        let reviewSets = sets.filter { $0.schedule == .review }.map { $0.id }
        setArrayOfString(key: .studySets, value: studySets)
        setArrayOfString(key: .reviewSets, value: reviewSets)
        setArrayOfString(key: .reviewedSets, value: [])
        setDate(key: .createdAt, value: Date())
    }
    
    func updateSchedule(todaySchedule: TodaySchedule) {
        setArrayOfString(key: .studySets, value: todaySchedule.studyIDs)
        setArrayOfString(key: .reviewSets, value: todaySchedule.reviewIDs)
        setArrayOfString(key: .reviewedSets, value: todaySchedule.reviewedIDs)
        setDate(key: .createdAt, value: Date())
    }
    
    func addReviewedSet(reviewed: StudySet) {
        var reviewedIDs = arrayOfString(for: .reviewedSets)
        reviewedIDs.append(reviewed.id)
        setArrayOfString(key: .reviewedSets, value: reviewedIDs)
        setDate(key: .createdAt, value: Date())
    }
    
    private func arrayOfString(for key: UserDefaultKey) -> [String] {
        return userDefaults.stringArray(forKey: key.rawValue) ?? []
    }
    
    private func date(for key: UserDefaultKey) -> Date {
        return userDefaults.object(forKey: key.rawValue) as? Date ?? Date()
    }
    
    private func setDate(key: UserDefaultKey, value: Date) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    private func setArrayOfString(key: UserDefaultKey, value: [String]) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    private func remove(key: UserDefaultKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
    
}

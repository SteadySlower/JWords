//
//  Mock.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/05.
//

import Foundation

@testable import JWords

// MARK: [StudySet]

extension Array where Element == StudySet {
    static func testMock(none: Int, study: Int, review: Int) -> Self {
        var result = [StudySet]()
        for i in 0..<none {
            result.append(.init(index: i, setSchedule: .none))
        }
        for i in none..<(none + study) {
            result.append(.init(index: i, setSchedule: .study))
        }
        for i in (none+study)..<(none + study + review) {
            result.append(.init(index: i, setSchedule: .review))
        }
        return result
    }
}

// MARK: TodaySchedule

extension TodaySchedule {
    static func testMock(ids: [String]) -> TodaySchedule {
        var validCombinations = [[Int]]()
        
        for i in 0...ids.count {
            for j in 0...(ids.count - i) {
                for k in 0...(ids.count - i - j) {
                    let l = ids.count - i - j - k
                    if i != 0 && j != 0 && k != 0 && l != 0 {
                        validCombinations.append([i, j, k, l])
                    }
                }
            }
        }
        
        let randomCombination = validCombinations.randomElement()!
        
        let numOfStudy = randomCombination[0]
        let numOfReview = randomCombination[1]
        let numOfReviewed = randomCombination[2]
        
        var ids = ids.shuffled()
        
        var study = [String]()
        var review = [String]()
        var reviewed = [String]()
        
        for i in 0..<numOfStudy {
            study.append(ids[i])
        }
        
        for j in numOfStudy..<(numOfStudy + numOfReview) {
            review.append(ids[j])
        }
        
        for k in (numOfStudy + numOfReview)..<(numOfStudy + numOfReview + numOfReviewed) {
            reviewed.append(ids[k])
        }
        
        return .init(
            studyIDs: study,
            reviewIDs: review,
            reviewedIDs: reviewed,
            createdAt: Date()
        )
    }
}

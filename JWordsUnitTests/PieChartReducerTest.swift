//
//  PieChartReducerTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/28/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class PieChartReducerTest: XCTestCase {
    
    func test_startAnimation() async {
        let clock = TestClock()
        let percentage = Float.random(in: 0..<1.0)
        
        let store = TestStore(
            initialState: PieChartReducer.State(
                _percentage: percentage
            ),
            reducer: { PieChartReducer() },
            withDependencies: {
                $0.continuousClock = clock
            }
        )
        
        await store.send(.startAnimation)
        
        for _ in 0..<200 {
            await clock.advance(by: .seconds(0.005))
            await store.receive(.addToDisplayPercentage(percentage / 200)) {
                $0.displayPercentage += percentage / 200
                if $0.displayPercentage > $0._percentage {
                    $0.displayPercentage = $0._percentage
                }
            }
        }
        
        await clock.run()
    }
    
    func test_addToDisplayPercentage() async {
        let percentage = Float.random(in: 0..<1.0)
        let addPercentage = percentage - Float.random(in: 0..<percentage)
        
        let store = TestStore(
            initialState: PieChartReducer.State(
                _percentage: percentage
            ),
            reducer: { PieChartReducer() }
        )
        
        await store.send(.addToDisplayPercentage(addPercentage)) {
            $0.displayPercentage += addPercentage
        }
    }
    
    func test_addToDisplayPercentage_biggerThanPercentage() async {
        
    }
    
}

//
//  EditHuriganaTextTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 11/3/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class EditHuriganaTextTest: XCTestCase {
    
    @MainActor
    func test_onGanaUpdated() async {
        let huris: [Huri] = .testMock
        let toUpdate = huris.randomElement()!
        let updated = Huri(id: toUpdate.id, huriString: Random.string)
        
        let store = TestStore(
            initialState: EditHuriganaText.State(huris: huris),
            reducer: { EditHuriganaText() }
        )
        
        await store.send(.onGanaUpdated(updated)) {
            $0.updateHuri(updated)
        }
        
        await store.receive(.onHuriUpdated)
    }
    
}

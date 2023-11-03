//
//  EditHuriganaTextTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 11/3/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class EditHuriganaTextTest: XCTestCase {
    
    func test_onGanaUpdated() async {
        let toBeUpdatedHuri = Huri(id: Random.string, huriString: Random.string)
        var mockHuris = [toBeUpdatedHuri]
        (0..<Random.int(from: 0, to: 100)).forEach { _ in
            mockHuris.append(Huri(id: Random.string, huriString: Random.string))
        }
        mockHuris = mockHuris.shuffled()
        let updatedHuri = Huri(id: toBeUpdatedHuri.id, huriString: Random.string)
        
        let store = TestStore(
            initialState: EditHuriganaText.State(huris: mockHuris),
            reducer: { EditHuriganaText() }
        )
        
        await store.send(.onGanaUpdated(updatedHuri)) {
            $0.updateHuri(updatedHuri)
        }
        
        await store.receive(.onHuriUpdated)
    }
    
}

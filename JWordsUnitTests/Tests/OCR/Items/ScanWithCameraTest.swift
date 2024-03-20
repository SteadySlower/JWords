//
//  ScanWithCameraTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class ScanWithCameraTest: XCTestCase {
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: ScanWithCamera.State(),
            reducer: { ScanWithCamera() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
}

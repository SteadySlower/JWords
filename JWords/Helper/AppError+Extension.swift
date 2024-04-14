//
//  AppError+Extension.swift
//  JWords
//
//  Created by JW Moon on 4/7/24.
//

import ComposableArchitecture
import ErrorKit

extension AppError {
    func simpleAlert<T>(action: T.Type) -> AlertState<T> {
        return AlertState<T> {
          TextState("에러")
        } actions: {
          ButtonState(role: .cancel) {
            TextState("확인")
          }
        } message: {
            TextState(self.errorMessage)
        }
    }
}

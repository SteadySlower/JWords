//
//  Synchronize.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

// use to synchronize view's FocusState and the store's state

public extension View {
  func synchronize<Value>(
    _ first: Binding<Value>,
    _ second: FocusState<Value>.Binding
  ) -> some View {
    self
      .onChange(of: first.wrappedValue) { second.wrappedValue = first.wrappedValue }
      .onChange(of: second.wrappedValue) { first.wrappedValue = second.wrappedValue }
  }
}

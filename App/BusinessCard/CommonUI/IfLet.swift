//
//  IfLet.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI

struct IfLet<T, Out: View>: View {
  let value: T?
  let produce: (T) -> Out

  init(_ value: T?, produce: @escaping (T) -> Out) {
    self.value = value
    self.produce = produce
  }

  var body: some View {
    Group {
      if value != nil {
        produce(value!)
      }
    }
  }
}

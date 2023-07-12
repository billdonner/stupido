//
//  Subs.swift
//  tcaqa
//
//  Created by bill donner on 7/12/23.
//

import SwiftUI
struct Bordered: ViewModifier {
  let opacity: Double
  let color:Color
    func body(content: Content) -> some View {
        content
        .padding()
        .background(color.opacity(opacity))
        .cornerRadius(10)
    }
}
extension View {
  func borderedStyle(_ color:Color = .clear)->some View {
    modifier(Bordered(opacity: 0.04,color:color))
  }
  func borderedStyleStrong(_ color:Color = .clear)->some View {
    modifier(Bordered(opacity: 0.1,color:color))
  }
}

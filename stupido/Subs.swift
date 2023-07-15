//
//  Subs.swift
//  tcaqa
//
//  Created by bill donner on 7/12/23.
//

import SwiftUI

let formatter = DateComponentsFormatter()
func timeStringFor(seconds : Int) -> String
{
  formatter.allowedUnits = [.second, .minute, .hour]
  formatter.zeroFormattingBehavior = .pad
  let output = formatter.string(from: TimeInterval(seconds))!
  let x =  seconds < 3600 ? String(output[output.firstIndex(of: ":")!..<output.endIndex]) : output
  return String(x.trimmingCharacters(in: .whitespaces).dropFirst())
}


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

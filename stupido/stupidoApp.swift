//
//  stupidoApp.swift
//  stupido
//
//  Created by bill donner on 7/12/23.
//

import SwiftUI
import ComposableArchitecture
import q20kshare

@main
struct stupidoApp: App {
//  static let onlyStore =     Store(initialState:ChallengeFeature.State(
//    challenges:SampleData.challenges, questionNumber:0, scoreDatum: SampleData.scoreDatum,
//    outcomes:SampleData.outcomes ))
//  {  ChallengeFeature( )._printChanges()  }
   
  static let onlyStore = Store(initialState: TopicsFeature.State()) {
  TopicsFeature()//._printChanges()
  }
  
  var body: some Scene {
    WindowGroup {
      let _ = print("Stupido is running")
      TopicsView(topicsStore:stupidoApp.onlyStore)
    }
  }
}

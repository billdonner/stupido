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
  static let challengeStore =     Store(initialState:ChallengeFeature.State(
    challenges:SampleData.challenges,
    scoreDatum: SampleData.scoreDatum,
    outcomes:SampleData.outcomes,
    questionNumber:0 ))
  {  ChallengeFeature( )  }
   
  static let topicStore = Store(initialState: TopicsFeature.State()) {
    TopicsFeature()//._printChanges()
  }
  
  var body: some Scene {
    WindowGroup {
      let _ = print("Stupido is running")
      ChallengeView(challengeStore: Self.challengeStore)
      //TopicsView(topicsStore:stupidoApp.topicStore)
    }
  }
}

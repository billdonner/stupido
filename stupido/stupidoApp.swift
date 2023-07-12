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
  static let scoreDatum = ScoreDatum()
  
  static let challengeStore = Store(initialState: ChallengeFeature.State()) {
    ChallengeFeature(scoreDatum: scoreDatum, ch: SampleData.challenge, idx: 1)._printChanges()
  }
  static let topicStore = Store(initialState: TopicsFeature.State()) {
    TopicsFeature(scoreDatum: scoreDatum)//._printChanges()
  }

  var body: some Scene {
    WindowGroup {
      //ChallengeView(challengeStore: tcaqaApp.challengeStore, scoreDatum: tcaqaApp.scoreDatum, challenge: SampleData.challenge, questionNumber: 456, questionMax: 999)
      TopicsView(topicsStore:stupidoApp.topicStore, scoreDatum: ScoreDatum.reloadOrInit())
    }
  }
}
//
//  tcaqaApp.swift
//  tcaqa
//
//  Created by bill donner on 7/9/23.
//
import ComposableArchitecture
import SwiftUI
import q20kshare




struct SampleData {
  static let opinions = [
    Opinion(id: "1234-5678-91011", truth: false, explanation: "blah blah blah blah blah blah blah blah", opinionID: "9999999", source: "billbot-070-v2"),
    Opinion(id: "932823-abcd0393-11", truth: true, explanation: "blah blah blah blah blah blah blah blah", opinionID: "9999998", source: "bard-023-v3")
  ]
  static let challenge = Challenge(question: "Why is the sky blue?", topic: "Nature", hint: "It's not green", answers: ["good","bad","ugly"], correct: "good",id:"aa849-2339-23bcd", opinions:opinions)

}


//this global scoring data should be persisted


@main
struct tcaqaApp: App {
  static let scoreDatum = ScoreDatum()
  
  static let challengeStore = Store(initialState: ChallengeFeature.State()) {
    ChallengeFeature(scoreDatum: scoreDatum, ch: SampleData.challenge,idx:1)._printChanges()
  }
  static let topicStore = Store(initialState: TopicsFeature.State()) {
    TopicsFeature(scoreDatum: scoreDatum)//._printChanges()
  }

  var body: some Scene {
    WindowGroup {
      //ChallengeView(challengeStore: tcaqaApp.challengeStore, scoreDatum: tcaqaApp.scoreDatum, challenge: SampleData.challenge, questionNumber: 456, questionMax: 999)
      TopicsView(topicsStore:tcaqaApp.topicStore, scoreDatum: ScoreDatum.reloadOrInit())
    }
  }
}

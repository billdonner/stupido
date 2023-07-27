//
//  stupidoApp.swift
//  stupido
//
//  Created by bill donner on 7/12/23.
//

import SwiftUI
import ComposableArchitecture
import q20kshare

/*
 try to keep GameData from chatGPT as a nearly static global since its only loaded at app start or in the background
 */
var gameDatum : IdentifiedArrayOf<GameData> = []


@main
struct stupidoApp: App {
//  static let onlyStore =     Store(initialState:ChallengeFeature.State(
//    challenges:SampleData.challenges,
//    questionNumber:0 ))
//  {  ChallengeFeature( )._printChanges()  }
   
  static let onlyStore = Store(initialState: TopicsFeature.State()) {
  TopicsFeature()//._printChanges()
  }
  
  var body: some Scene {
    WindowGroup {
      TopicsView(topicsStore:stupidoApp.onlyStore)
    }
  }
}

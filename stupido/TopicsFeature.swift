//
//  TopicsFeature.swift
//  tcaqa
//
//  Created by bill donner on 7/10/23.
//

import ComposableArchitecture
import SwiftUI
import q20kshare

/*
 try to keep GameData from chatGPT as a static global
 */
var gameDatum : [GameData] = []

struct TopicsFeature: ReducerProtocol {
   //let scoreDatum: ScoreDatum
  struct State:Equatable {
    static func == (lhs: TopicsFeature.State, rhs: TopicsFeature.State) -> Bool {
      lhs.topic == rhs.topic &&
       lhs.showChallenge == rhs.showChallenge
    }
    

    @PresentationState var showChallenge: ChallengeFeature.State?
    var isLoading = false
    var topic = ""
  }
  
  enum Action:Equatable {
    case showChallenge(PresentationAction<ChallengeFeature.Action>)

    case reloadButtonTapped
    case reloadButtonResponse([GameData])
  }
  var body: some ReducerProtocolOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
        
      case let .reloadButtonResponse(gameData):
        gameDatum = gameData
        state.isLoading = false
        state.topic = gameData[0].subject // just capture first to start 
        state.showChallenge!.scoreDatum.setScoresFromGameData(gameData)
        print("Data loaded \(gameData.count) topics")
        return .none
        
      case .reloadButtonTapped: if !state.isLoading {
        gameDatum = []
        state.isLoading = true
        return .run { //[count = state.count]
          send in
          let count = 1
          let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://billdonner.com/fs/gs/readyforios\(count)")!)
          let gd = try JSONDecoder().decode([GameData].self,from:data)
          await send(.reloadButtonResponse(gd))
        }
      }
    //  case .showChallenge(_):
       // state.showChallenge = ChallengeFeature.State(topic:  state.showChallenge!.topic)
        
      case .showChallenge :
        let topic = state.topic
        state.showChallenge = ChallengeFeature.State(topic:topic)
      }
      return .none
    } 
    .ifLet(\.$showChallenge, action: /Action.showChallenge) {
      ChallengeFeature()
    }
  }
}

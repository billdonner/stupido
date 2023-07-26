//
//  TopicsFeature.swift
//  tcaqa
//
//  Created by bill donner on 7/10/23.
//

import ComposableArchitecture
import SwiftUI
import q20kshare


struct TopicsFeature: ReducerProtocol {

  struct State:Equatable {
    static func == (lhs: TopicsFeature.State, rhs: TopicsFeature.State) -> Bool {
      lhs.selectedTopic == rhs.selectedTopic &&
       lhs.showChallenge == rhs.showChallenge
    }
    @PresentationState var showChallenge: ChallengeFeature.State?
    var isLoading = false
    var selectedTopic = ""
    var challengeFeature = ChallengeFeature.State()

    mutating func clearAllScores(_ gameData:[GameData]) {
      challengeFeature.scoresByTopic = [:]
      for gd in gameData {
        challengeFeature.scoresByTopic[gd.subject]=ScoreData(topic:gd.subject,
                                            outcomes:Array(repeating: ChallengeOutcomes.unplayed,
                                              count: gd.challenges.count))
      }
    }
  }
  
  enum Action:Equatable {
    case topicRowTapped(PresentationAction<ChallengeFeature.Action>)
    case reloadButtonTapped
    case reloadButtonResponse([GameData])
  }
  
  var body: some ReducerProtocolOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
        
      case let .reloadButtonResponse(gameData):
        gameDatum = IdentifiedArray(uniqueElements: gameData)
        state.isLoading = false
        state.clearAllScores(gameData)
        
        state.challengeFeature.scoresByTopic = [:]
        for gd in gameData {
          state.challengeFeature.scoresByTopic[gd.subject]=ScoreData(topic:gd.subject,
                                              outcomes:Array(repeating: ChallengeOutcomes.unplayed,
                                                count: gd.challenges.count))
        }
        state.selectedTopic = gameData.map{$0.subject}[0]
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

      case .topicRowTapped :
        state.showChallenge = state.challengeFeature //ChallengeFeature.State(topic:state.selectedTopic)
      }
      return .none
    } 
    .ifLet(\.$showChallenge, action: /Action.topicRowTapped) {
      ChallengeFeature()
    }
  }
}

//    mutating func adjustScoresFromOutComeForTopic(_ topic:String,idx:Int, outcome:ChallengeOutcomes,by n:Int=1) {
//      let x = challengeFeature.scoresByTopic[topic]
//      guard let x = x else {return}
//      var cha = x.outcomes
//      cha[idx] = outcome
//      challengeFeature.scoresByTopic[topic] = ScoreData(topic:topic, outcomes:cha)
//    }
//  case .showChallenge(_):
   // state.showChallenge = ChallengeFeature.State(topic:  state.showChallenge!.topic)
    

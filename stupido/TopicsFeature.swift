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
      
      lhs.challengeFeature.topic == rhs.challengeFeature.topic &&
       lhs.showChallenge == rhs.showChallenge
    }
    @PresentationState var showChallenge: ChallengeFeature.State?
    var isLoading = false
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
    case showTopicButtonTapped(Int)
    case showTopic(PresentationAction<ChallengeFeature.Action>)
    case reloadButtonTapped
    case reloadButtonResponse([GameData])
  }
  
  var body: some ReducerProtocolOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
        
      case let .reloadButtonResponse(gd):
 
        state.challengeFeature.topic = gd.map{$0.subject}[0]
        state.challengeFeature.challenges = gd.map {$0.challenges} [0]
        state.challengeFeature.scoresByTopic = [:]
        for gdd in gd {
          state.challengeFeature.scoresByTopic[gdd.subject]=ScoreData(topic:gdd.subject,
                                              outcomes:Array(repeating: ChallengeOutcomes.unplayed,
                                                count: gdd.challenges.count))
        }
        state.isLoading = false
        state.clearAllScores(gd)
        
        gameDatum = gd//IdentifiedArray(uniqueElements: gd)
        print("Stupidio loaded \(gameDatum.count) topics")
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

      case .showTopicButtonTapped(let idx) :
       //move in the data for challengeview
        state.challengeFeature.topic = gameDatum[idx].subject
        state.challengeFeature.challenges = gameDatum[idx].challenges 
        state.challengeFeature.timerCount = 0
        state.challengeFeature.isTimerRunning = false
        state.challengeFeature.questionNumber = 0
   
        state.showChallenge = state.challengeFeature //ChallengeFeature.State(topic:state.selectedTopic)
      case .showTopic(_):
        return .none 
      }
      return .none
    } 
    .ifLet(\.$showChallenge, action: /Action.showTopic ) {
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
    

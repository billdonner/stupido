//
//  TopicsFeature.swift
//  tcaqa
//
//  Created by bill donner on 7/10/23.
//

import ComposableArchitecture
import SwiftUI
import q20kshare

struct TopicsView: View {
  
  struct ViewState: Equatable {
    var sd:ScoreDatum
    let gameDatum:[GameData]
    let isLoading:Bool
    
     init(state: TopicsFeature.State) {
       self.sd = state.scoreDatum
       self.gameDatum = state.gameDatum
       self.isLoading = state.isLoading
     }
   }
  
  
  let topicsStore:StoreOf<TopicsFeature>

  var body: some View {
    WithViewStore( topicsStore,observe:ViewState.init){viewStore in
      VStack {
        Text("Total Score Across Topics: \(viewStore.sd.grandScore)")
        Text("Topics: \(viewStore.gameDatum.count)")
        Text("Challenges: \(viewStore.gameDatum.map {$0.challenges.count}.reduce(0,+))")
        
        ForEach (viewStore.gameDatum){ gameData in
          let score = viewStore.sd.scoresByTopic[gameData.subject]?.topicScore ?? -1
          let hwm = viewStore.sd.scoresByTopic[gameData.subject]?.highWaterMark ?? -1
          let h = hwm == -1 ? "unplayed of" : "\(hwm)"
          HStack {
            Text("score \(score)").font(.footnote)
            Text(gameData.subject).font(.title).lineLimit(2)
            Text("\(h)").font(.footnote)
            Text("\(gameData.challenges.count)").font(.footnote)
          }
        }

        if viewStore.isLoading {
          ProgressView().progressViewStyle(.automatic)
            .foregroundColor(.red).background(.blue)
        } else {
          Button("Reload"){viewStore.send(.reloadButtonTapped)}.padding()
        }
      }
      .task {
        viewStore.send(.reloadButtonTapped)
      }
    }
  }
}
struct TopicsPreview: PreviewProvider {
  static var previews: some View {
    TopicsView(
      topicsStore: Store(initialState: TopicsFeature.State()) {
        TopicsFeature()
      }
    )
  }
}

struct TopicsFeature: ReducerProtocol {
   //let scoreDatum: ScoreDatum
  struct State:Equatable {
    static func == (lhs: TopicsFeature.State, rhs: TopicsFeature.State) -> Bool {
       lhs.gameDatum == rhs.gameDatum
    }
    
    var isLoading = false
    var gameDatum : [GameData] = []
    var scoreDatum =  ScoreDatum.reloadOrInit ()
  }
  
  enum Action {
    case reloadButtonTapped
    case reloadButtonResponse([GameData])
  }
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      
    case let .reloadButtonResponse(gameData):
        state.gameDatum = gameData
        state.isLoading = false
        state.scoreDatum.setScoresFromGameData(gameData)
      print("Data loaded \(gameData.count) topics")
        return .none
      
    case .reloadButtonTapped: if !state.isLoading {
      state.gameDatum = []
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
    }
    return .none
  }
}

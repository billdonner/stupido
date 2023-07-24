//
//  TopicsView.swift
//  stupido
//
//  Created by bill donner on 7/22/23.
//
 
import ComposableArchitecture
import SwiftUI
import q20kshare

// gameData is now handled as an global, not included in any  Feature State

struct TopicsViewState: Equatable {
  var sd:ScoreDatum
  let isLoading:Bool
  let topic:String
   init(state: TopicsFeature.State) {
     self.sd = state.showChallenge!.scoreDatum
    // self.gameDatum = state.gameDatum
     self.isLoading = state.isLoading
     self.topic = state.topic
   }
 }
struct ScoreView: View {
  let score:Int
  let c:String
  let i:String
  var body: some View {
    HStack {
      Spacer()
      Text("\(score)").font(.title)
      VStack {
        Text(c).font(.footnote)
        Text(i).font(.footnote)
      }
    }
  }
}
struct TopicsView: View {
  let topicsStore:StoreOf<TopicsFeature>
  var body: some View {
    NavigationStack {
      WithViewStore( topicsStore,observe:TopicsViewState.init){viewStore in
        VStack {
          ScrollView {
              
              ForEach(Array(zip(1..., gameDatum)), id: \.1.id) { number, gameData in
              let sbt = viewStore.sd.scoresByTopic[gameData.subject]
              let score = sbt?.topicScore ?? -1
              let hwm = sbt?.highWaterMark ?? -1
              let h = hwm == -1 ? "😎" : "\(hwm)"
              let cwm = sbt?.playedCorrectly ?? -1
              let c = cwm == -1 ? "😎" : "\(cwm)"
              let iwm = sbt?.playedInCorrectly ?? -1
              let i = iwm == -1 ? "😎" : "\(iwm)"
              HStack {
                VStack{
                  Text(h).font(.footnote)
                  Text("\(gameData.challenges.count)").font(.footnote)
                }
              Text(gameData.subject).font(.title).lineLimit(2)
                  .onTapGesture {
                    viewStore.send(.rowTapped(number))
                  }
                ScoreView ()
              }.borderedStyleStrong(.blue).padding(.horizontal)
            
            }
          }
          if viewStore.isLoading {
            ProgressView().progressViewStyle(.automatic)
              .foregroundColor(.red).background(.blue)
          } else {
           // Button("Reload"){viewStore.send(.reloadButtonTapped)}.padding()
          }
        }
        .toolbar {
          ToolbarItemGroup(placement:.navigation){
            HStack {
              HStack{
                Text("Score:\(viewStore.sd.grandScore)")
                Text("Topics:\(gameDatum.count)")
                Text("Challenges:\(gameDatum.map {$0.challenges.count}.reduce(0,+))")
              }.font(.footnote)
              Spacer()
              Text ("       Q20K").font(.headline)
            }
            Spacer()
            Button(action:{}){
              Image(systemName: "gear").font(.headline)
            }
          }//.monospaced()
        }
        .sheet(
          store: self.topicsStore.scope(
            state: \.$showChallenge,
            action: { .showChallenge($0) }
          )
        ) { store in
          NavigationStack {
            ChallengeView(challengeStore: store)
          }
        }
        .navigationTitle("Today's Topics")
        .task {
          viewStore.send(.reloadButtonTapped)
        }
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

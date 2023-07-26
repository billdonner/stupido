//
//  TopicsView.swift
//  stupido
//
//  Created by bill donner on 7/22/23.
//
 
import ComposableArchitecture
import SwiftUI
import q20kshare


struct TopicsView: View {
  
  struct ViewState: Equatable {
    let isLoading:Bool
    let topic:String
    let scoresByTopic:[String:ScoreData]
    let grandScore:Int
     init(state: TopicsFeature.State) {
       self.isLoading = state.isLoading
       self.topic = state.selectedTopic
       self.scoresByTopic =  state.challengeFeature.scoresByTopic
       self.grandScore = state.challengeFeature.grandScore
     }
   }
  
  let topicsStore:StoreOf<TopicsFeature>
  var body: some View {
    NavigationStack {
      WithViewStore( topicsStore,observe:ViewState.init){viewStore in
        VStack {
          ScrollView {
           // ForEach(Array(zip(1..., gameDatum)), id: \.1.id) { number, gameData in
            ForEach(gameDatum ) {  gameData in
              if  let sbt = viewStore.scoresByTopic[gameData.subject] {
                OneRowView(sbt:sbt,gameData:gameData )
                  .onTapGesture {
                   // viewStore.send(.topicRowTapped(ChallengeFeature.Action.onceOnlyVirtualyTapped))
                    
                    print("must figure out what to do for tap on \(sbt.topic)")
                  }
              }
            }// for each
          }// scrollview
       
        if viewStore.isLoading {
          ProgressView().progressViewStyle(.automatic)
            .foregroundColor(.red).background(.blue)
        }
      }
        .toolbar {
          ToolbarItemGroup(placement:.navigation){
            HStack {
              HStack{
                Text("Score:\(viewStore.grandScore)")
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
            action: { .topicRowTapped($0) }
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
      
    }//nAVstack
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
struct RightistView: View {
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
struct LeftistView: View {
  let h:String
  let gameData:GameData
  var body: some View {
      VStack{
        Text(h).font(.footnote)
        Text("\(gameData.challenges.count)").font(.footnote)
      }
  }
}
struct OneRowView: View {
  let sbt:ScoreData
  let gameData:GameData
  var body: some View {
    VStack {
      HStack {
        let hwm = sbt.highWaterMark //?? -1
        let h = hwm == -1 ? "😎" : "\(hwm)"
        LeftistView(h: h, gameData:gameData)
        
        Text(gameData.subject).font(.title2).lineLimit(2)
    
      Spacer()
      let cwm = sbt.playedCorrectly //?? -1
      let c = cwm == -1 ? "😎" : "\(cwm)"
      let iwm = sbt.playedInCorrectly// ?? -1
      let i = iwm == -1 ? "😎" : "\(iwm)"
      let score = sbt.playedCorrectly //- sbt.playedInCorrectly//
      RightistView (score: score, c: c, i: i)
      }
    }
    .borderedStyleStrong(.blue).padding(.horizontal)

  }
}

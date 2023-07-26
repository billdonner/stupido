//
//  ChallengeView.swift
//  stupido
//
//  Created by bill donner on 7/15/23.
//

import ComposableArchitecture
import SwiftUI
import q20kshare

struct ChallengeViewState: Equatable {
  let challenges: [Challenge]
  let scoresByTopic: [String:ScoreData]
  let showing:  Showing
  let timerCount: Int
  let questionNumber:Int
  let questionMax:Int
  let thisChallenge:Challenge
  let thisOutcome: ChallengeOutcomes
  let outcomes:[ChallengeOutcomes]
  var topicScore:Int
  let grandScore:Int
 // var once: Bool
  
  init(state: ChallengeFeature.State) {
    
    self.thisChallenge = state.challenges[state.questionNumber]
    let topic = self.thisChallenge.topic
    let x = state.scoresByTopic[topic] ?? ScoreData.default
    self.outcomes = x.outcomes
    self.scoresByTopic = state.scoresByTopic
    self.challenges = state.challenges
   // assert(self.challenges.count == state.outcomes.count , "size MisMatch")
    self.showing = state.showing
    self.timerCount = state.timerCount
    self.questionMax = state.challenges.count - 1
    self.questionNumber = state.questionNumber
    self.thisOutcome = x.outcomes[questionNumber]
    self.topicScore = x.outcomes.reduce(0) { $0 + ($1 == .playedCorrectly ? 1 : 0)}
    self.grandScore = state.grandScore
   // self.once = state.once
  }
}

struct ChallengeView: View {
  let challengeStore:StoreOf<ChallengeFeature>
  var body: some View {
    NavigationStack{
      //, removeDuplicates :==
      WithViewStore(challengeStore,observe: ChallengeViewState.init  ){viewStore in
        let tc = viewStore.thisChallenge
        let th =  viewStore.thisOutcome
        VStack { // a place to hang the nav title
          VStack{
//
          // SHOW Question
              VStack{
                ZStack {
                  let t:Color = switch( th ){
                  case .unplayed:
                      .clear
                  case .playedCorrectly:
                      .green
                  case .playedIncorrectly:
                      .red
                  }
                  Circle().frame(width:10).offset(x:122,y:-22).foregroundColor(t)
        
                  Text(tc.question).font(.title) 
                }
              }
            .borderedStyleStrong(.blue)
      
            //SHOW   Answers
            // ensure we never go out of bounds regardless of how many answers
            VStack {
              let t = th != .unplayed
              if tc.answers.count>0 {
                Button(action:{viewStore.send(.answer1ButtonTapped)}){
                  Text(tc.answers[0]).padding()
                }.foregroundColor(  (t && tc.answers[0] == tc.correct) ? .green : ((t) ? .red : .blue))
              }
              if tc.answers.count>1 {
                Button(action:{viewStore.send(.answer2ButtonTapped)}){
                  Text(tc.answers[1]).padding()
                }.foregroundColor(  (t && tc.answers[1] == tc.correct) ? .green : ((t) ? .red : .blue))
              }
              if tc.answers.count>2 {
                Button(action:{viewStore.send(.answer3ButtonTapped)}){
                  Text(tc.answers[2]).padding()
                }.foregroundColor(  (t && tc.answers[2] == tc.correct) ? .green : ((t) ? .red : .blue))
              }
              if tc.answers.count>3 {
                Button(action:{viewStore.send(.answer4ButtonTapped)}){
                  Text(tc.answers[3]).padding()
                }.foregroundColor(  (t && tc.answers[3] == tc.correct) ? .green : ((t) ? .red : .blue))
              }
              if tc.answers.count>4 {
                Button(action:{viewStore.send(.answer5ButtonTapped)}){
                  Text(tc.answers[4]).padding()
                }.foregroundColor(  (t && tc.answers[4] == tc.correct) ? .green : ((t) ? .red : .blue))
              }
            }
          }.font(.largeTitle).borderedStyle(.gray)
            .task{
              viewStore.send(.onceOnlyVirtualyTapped)
            }
          Spacer()
          //SHOW Hint and Answers
          VStack {
            switch viewStore.showing {
            case .qanda:
              Button("Hint"){
                viewStore.send(.hintButtonTapped)
              }
            case .hint:
              Text("Hint:" + tc.hint).font(.headline)
            case .answerWasCorrect:
              Text("Answer: " + tc.correct).font(.title)
                .borderedStyleStrong( .green)
              if tc.opinions.count > 0 {
                Text(tc.opinions[0].explanation)
                  .borderedStyleStrong(.green)
              }
            case .answerWasIncorrect:
              Text("Answer: " + tc.correct).font(.title)
                .borderedStyleStrong( .red)
              if tc.opinions.count > 0 {
                let explanation = tc.opinions[0].explanation
                Text(explanation)
                  .borderedStyleStrong( .red)
              }
            }
          }
          Spacer()
          //Show Expertise and Divider
          VStack {
            ExpertiseView (outcomes:viewStore.outcomes)
              .padding(.horizontal)
            Divider()
              .toolbar {
                ToolbarItemGroup(placement:.navigation){
                  Button(action:{}){
                    Text("Topics").font(.headline)
                  }
                  Spacer()
                  HStack{
                    Spacer()
                    Text("Question \(viewStore.questionNumber+1)" + "/" + "\(viewStore.questionMax+1)")
                    Spacer()
                    Text("\(timeStringFor(seconds:viewStore.timerCount))")
                    Spacer( )
                    Text("Score \( viewStore.topicScore)" + "/" + "\(viewStore.grandScore)")
                  }.monospaced().font(.footnote)
                }//.monospaced()
              }
              .toolbar {
                ToolbarItemGroup(placement: .bottomBar){
                  Button {
                    viewStore.send(.previousButtonTapped)
                  } label: {
                    Image(systemName: "arrow.left")
                  }.disabled(viewStore.questionNumber <= 0)
                  Spacer()
                  Button {
                    viewStore.send(.thumbsDownButtonTapped)
                  } label: {
                    Image(systemName: "hand.thumbsdown")
                  }.disabled(viewStore.showing == .hint || viewStore.showing == .qanda)
                  Spacer()
                  Button{
                    viewStore.send(.infoButtonTapped)
                  }  label: {
                    Image(systemName: "info.circle")
                  }
                  Spacer()
                  Button {
                    viewStore.send(.thumbsUpButtonTapped)
                  } label: {
                    Image(systemName: "hand.thumbsup")
                  }.disabled(viewStore.showing == .hint || viewStore.showing == .qanda)
                  
                  Spacer()
                  Button {
                    viewStore.send(.nextButtonTapped)
                  } label: {
                    Image(systemName: "arrow.right")
                  }.disabled(viewStore.questionNumber >= viewStore.questionMax)
                }
              }
              .sheet(
                store: self.challengeStore.scope(
                  state: \.$showInfoView,
                  action: { .showInfo($0) }
                )
              ) { store in
                NavigationStack {
                  ShowInfoView(store: store)
                }
              }
              .sheet(
                store: self.challengeStore.scope(
                  state: \.$showThumbsUpView,
                  action: { .thumbsUp($0) }
                )
              ) { store in
                NavigationStack {
                  ThumbsUpView(store: store)
                }
              }
              .sheet(
                store: self.challengeStore.scope(
                  state: \.$showThumbsDownView,
                  action: { .thumbsDown($0) }
                )
              ) { store in
                NavigationStack {
                  ThumbsDownView(store: store)
                }
              }
          }.navigationTitle(tc.topic)
        } // place to hang
      }
    }// nav stack
  }
}
struct ChallengeView_Previews: PreviewProvider {
  static var previews: some View {
      ChallengeView(challengeStore: Store(initialState:ChallengeFeature.State(
        challenges:SampleData.challenges, questionNumber:0 ))  {ChallengeFeature()} )
    
  }
}

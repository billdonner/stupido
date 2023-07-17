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
    let outcomes:[ScoreDatum.ChallengeOutcomes]
    let showing:  Showing
    let timerCount: Int
    let questionNumber:Int
    let questionMax:Int
    let scoreDatum:ScoreDatum
    let thisChallenge:Challenge
    let thisOutcome: ScoreDatum.ChallengeOutcomes
    var topicScore:Int
    var once: Bool
 
     init(state: ChallengeFeature.State) {
       self.challenges = state.challenges
       self.outcomes = state.outcomes
       assert(self.challenges.count == state.outcomes.count , "size MisMatch")
       self.showing = state.showing
       self.timerCount = state.timerCount
       self.questionMax = state.challenges.count - 1
       self.questionNumber = state.questionNumber
       self.scoreDatum = state.scoreDatum
       self.thisChallenge = state.challenges[state.questionNumber]
       self.thisOutcome = state .outcomes[state.questionNumber]
       self.topicScore = state.topicScore
       self.once = state.once
     }
   }
  
struct ChallengeView: View { 
  let challengeStore:StoreOf<ChallengeFeature>
  var body: some View {
    //, removeDuplicates :==
    WithViewStore(challengeStore,observe: ChallengeViewState.init  ){viewStore in
      let tc = viewStore.thisChallenge
 
      VStack{
        VStack {
          HStack {
            Text("Grand Score \(viewStore.scoreDatum.grandScore)")
            Spacer()
            Text("\(timeStringFor(seconds:viewStore.timerCount))")
            Spacer( )
            Text("Topic Score  \( viewStore.topicScore) ")
          }.font(.footnote).padding(.horizontal)
        }
  VStack {
            
            VStack{
              HStack {
                Text("Question \(viewStore.questionNumber+1)" + "/" + "\(viewStore.questionMax+1)")
                Spacer()
                Text("Topic \( tc.topic)")
              }.font(.footnote)
              Text(tc.question).font(.title)
              if viewStore.once {
                if  viewStore.outcomes [viewStore.questionNumber] != .unplayed
                {
                  Text ("You've already played this so we won't score your answer").font(.footnote)
                }
                else {
                  Text ("You've never played this.").font(.footnote)
                }
              } else {
                //Text("DIAG - viewStore.once is false").font(.caption)
                EmptyView()
              }
            }
          }
          .borderedStyleStrong(.gray)
          .padding()
          // ensure we never go out of bounds regardless of how many answers
          if tc.answers.count>0 {
            Button(tc.answers[0])
            {viewStore.send(.answer1ButtonTapped)}
          }
          if tc.answers.count>1 {
            Button(tc.answers[1])
            {viewStore.send(.answer2ButtonTapped)}
          }
          if tc.answers.count>2 {
            Button(tc.answers[2])
            {viewStore.send(.answer3ButtonTapped)}
          }
          if tc.answers.count>3 {
            Button(tc.answers[3])
            {viewStore.send(.answer4ButtonTapped)}
          }
          if tc.answers.count>4 {
            Button(tc.answers[4])
            {viewStore.send(.answer5ButtonTapped)}
          }
        } .font(.largeTitle) .borderedStyle(.gray)
          .task{
            viewStore.send(.onceOnlyVirtualyTapped)
          }
        Spacer()
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
     Spacer()
      VStack {
        ExpertiseView (outcomes:viewStore.outcomes)
          .padding(.horizontal)
        HStack {
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
        }.font(.title)
          .padding([.horizontal,.bottom])
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
    }
  
  }

struct ChallengeView_Previews: PreviewProvider {
  static var previews: some View {
    let scoreDatum = SampleData.scoreDatum
    ChallengeView(challengeStore: Store(initialState:ChallengeFeature.State( challenges:SampleData.challenges, scoreDatum: scoreDatum,questionNumber:0 ))
                  {  ChallengeFeature( )  } )
  }
}

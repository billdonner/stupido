//
//  ChallengeView.swift
//  stupido
//
//  Created by bill donner on 7/15/23.
//

import ComposableArchitecture
import SwiftUI
import q20kshare

func timeStringFor(seconds : Int) -> String
{
  let formatter = DateComponentsFormatter()
  formatter.allowedUnits = [.second, .minute, .hour]
  formatter.zeroFormattingBehavior = .pad
  let output = formatter.string(from: TimeInterval(seconds))!
  return seconds < 3600 ? String(output[output.firstIndex(of: ":")!..<output.endIndex]) : output
}


  struct ChallengeViewState: Equatable {
    let challenges: [Challenge]
    let outcomes:[ScoreDatum.ChallengeOutcomes]
    let showing: ChallengeFeature.State.Showing
    let timerCount: Int
    let questionNumber:Int
    let questionMax:Int
    let sd:ScoreDatum
    let thisChallenge:Challenge
    let thisOutcome: ScoreDatum.ChallengeOutcomes
    var unplayedMessage: String?

    
     init(state: ChallengeFeature.State) {
       self.challenges = state.challenges
       self.outcomes = state.outcomes
       assert(self.challenges.count == state.outcomes.count , "size MisMatch")
       self.showing = state.showing
       self.timerCount = state.timerCount
       self.questionMax = state.challenges.count - 1
       self.questionNumber = state.questionNumber
       self.sd = state.scoreDatum
       self.thisChallenge = state.challenges[state.questionNumber]
       self.thisOutcome = state .outcomes[state.questionNumber]
       self.unplayedMessage = state.unplayedMessage
     }
   }
  
struct ChallengeView: View {
  
  let challengeStore:StoreOf<ChallengeFeature>
  @State var unplayedMessage : String? = nil
 

  var body: some View {
    //, removeDuplicates :==
    WithViewStore(challengeStore,observe: ChallengeViewState.init  ){viewStore in
      let tc = viewStore.thisChallenge
    VStack{
        //let _ = print (viewStore.timerCount)
     // let challenges = viewStore.challenges
        VStack {
          HStack {
            Text("Grand Score \(viewStore.sd.grandScore)")
            Spacer()
            Text("\(timeStringFor(seconds:viewStore.timerCount))")
            Spacer( )
            Text("Topic Score  \( viewStore.sd.scoresByTopic[  tc.topic]?.topicScore ?? 0)")
          }.font(.footnote).padding(.horizontal)
        }
        Group {
          
          VStack {
            if  let msg = unplayedMessage   {
              Text (msg).font(.caption)
            }
            HStack {
              Text("Question \(viewStore.questionNumber)" + "/" + "\(viewStore.questionMax)")
              Spacer()
              Text("Topic \( tc.topic)")
            }.font(.footnote)
            Text(tc.question).font(.title)
          }
          .borderedStyleStrong(.gray)
          .padding()
      
          if tc.answers.count>0 {
            Button(tc.answers[0]){viewStore.send(.answer1ButtonTapped)}
          }
          if tc.answers.count>1 {
            Button(tc.answers[1]){viewStore.send(.answer2ButtonTapped)}
          }
          if tc.answers.count>2 {
            Button(tc.answers[2]){viewStore.send(.answer3ButtonTapped)}
          }
          if tc.answers.count>3 {
            Button(tc.answers[3]){viewStore.send(.answer4ButtonTapped)}
          }
          if tc.answers.count>4 {
            Button(tc.answers[4]){viewStore.send(.answer5ButtonTapped)}
          }
        } .font(.largeTitle) .borderedStyle(.gray)
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
              let explanation = tc.opinions[0].explanation
              Text(explanation)
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
     
        HStack {
          Button {
            viewStore.send(.previousButtonTapped)
          } label: {
            Image(systemName: "arrow.left")
          }.disabled(viewStore.questionNumber <= 0)
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
          Button {
            viewStore.send(.nextButtonTapped)
          } label: {
            Image(systemName: "arrow.right")
          }.disabled(viewStore.questionNumber >= viewStore.questionMax)
        }.font(.title)
          .padding([.horizontal,.bottom])
      }.task {
        // run once
        if viewStore.thisOutcome != .unplayed {
          unplayedMessage = "You have already played this... "
 
        }
        viewStore.send(.virtualTimerButtonTapped)
      }
    }
  }
}

struct ChallengeView_Previews: PreviewProvider {
  static var previews: some View {
    let scoreDatum = ScoreDatum()
    ChallengeView(challengeStore: Store(initialState:ChallengeFeature.State( scoreDatum: scoreDatum,
      challenges:SampleData.challenges, questionNumber:0 ))
                  {  ChallengeFeature( )  } )
  }
}

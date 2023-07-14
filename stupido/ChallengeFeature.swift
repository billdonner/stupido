import ComposableArchitecture
import SwiftUI
import q20kshare

struct ChallengeView: View {
  
  struct ChallengeViewState: Equatable {
    let challenge: Challenge
    let showing: ChallengeFeature.State.Showing
    let timerCount: Int
    let questionNumber:Int
    let questionMax:Int
    let sd:ScoreDatum
    
     init(state: ChallengeFeature.State) {
       self.challenge = state.challenge
       self.showing = state.showing
       self.timerCount = state.timerCount
       self.questionMax = state.questionMax
       self.questionNumber = state.questionNumber
       self.sd = state.scoreDatum
     }
   }
  
  let challengeStore:StoreOf<ChallengeFeature>

  var body: some View {
    //, removeDuplicates :==
    WithViewStore(challengeStore,observe: ChallengeViewState.init  ){viewStore in
    VStack{
        //let _ = print (viewStore.timerCount)
      let challenge = viewStore.challenge
        VStack {
          HStack {
            Text("Grand Score \(viewStore.sd.grandScore)")
            Spacer()
            Text("\(viewStore.timerCount)")
            Spacer( )
            Text("Topic Score  \( viewStore.sd.scoresByTopic[  challenge.topic]?.topicScore ?? 0)")
          }.font(.footnote).padding(.horizontal)
        }
        Group {
          
          VStack {
            HStack {
              Text("Question \(viewStore.questionNumber)" + "/" + "\(viewStore.questionMax)")
              Spacer()
              Text("Topic \( challenge.topic)")
            }.font(.footnote)
            Text( challenge.question).font(.title)
          }
          .borderedStyleStrong(.gray)
          .padding()
    
          if challenge.answers.count>0 {
            Button(challenge.answers[0]){viewStore.send(.answer1ButtonTapped)}
              .borderedStyle(.gray)
          }
          if challenge.answers.count>1 {
            Button(challenge.answers[1]){viewStore.send(.answer2ButtonTapped)}
              .borderedStyle(.gray)
          }
          if challenge.answers.count>2 {
            Button(challenge.answers[2]){viewStore.send(.answer3ButtonTapped)}
              .borderedStyle(.gray)
          }
          if challenge.answers.count>3 {
            Button(challenge.answers[3]){viewStore.send(.answer4ButtonTapped)}
              .borderedStyle(.gray)
          }
          if challenge.answers.count>4 {
            Button(challenge.answers[4]){viewStore.send(.answer5ButtonTapped)}
              .borderedStyle(.gray)
          }
        } .font(.largeTitle)
        Spacer()
      switch viewStore.showing {
          case .qanda:
            Button("Hint"){
              viewStore.send(.hintButtonTapped)
            }
          case .hint:
            Text("Hint:" + challenge.hint).font(.headline)
          case .answerWasCorrect:
            Text("Answer: " + challenge.correct).font(.title)
              .borderedStyleStrong( .green)
            if challenge.opinions.count > 0 {
              let explanation = challenge.opinions[0].explanation
              Text(explanation)
                .borderedStyleStrong(.green)
            }
          case .answerWasIncorrect:
            Text("Answer: " + challenge.correct).font(.title)
              .borderedStyleStrong( .red)
            if challenge.opinions.count > 0 {
              let explanation = challenge.opinions[0].explanation
              Text(explanation)
                .borderedStyleStrong( .red)
            }
          }
     
        HStack {
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
        }.font(.title)
          .padding([.horizontal,.bottom])
      }.task {
        // run once
        viewStore.send(.virtualTimerButtonTapped)
      }
    }
  }
}

struct ChallengeView_Previews: PreviewProvider {
  static var previews: some View {
    ChallengeView(challengeStore: Store(initialState:ChallengeFeature.State( )){
      ChallengeFeature( )
    }
                 )
  }
}
struct ChallengeFeature: ReducerProtocol {

  
  struct State :Equatable{
    static func == (lhs: ChallengeFeature.State, rhs: ChallengeFeature.State) -> Bool {
      lhs.showing == rhs.showing
      && lhs.timerCount == rhs.timerCount
    }
    
    enum Showing:Equatable {
      case qanda
      case hint
      case answerWasCorrect
      case answerWasIncorrect
    }
    var scoreDatum=ScoreDatum()
    var challenge:Challenge = SampleData.challenge

    var questionNumber:Int = 0
    var questionMax:Int = 0
    var showing:Showing = .qanda
    var isTimerRunning = false
    var timerCount = 0
    var topic : String {
      challenge.topic
    }
    
  }// end of state
  enum CancelID { case timer }
  enum Action {
    case answer1ButtonTapped
    case answer2ButtonTapped
    case answer3ButtonTapped
    case answer4ButtonTapped
    case answer5ButtonTapped
    case hintButtonTapped
    case infoButtonTapped
    case thumbsUpButtonTapped
    case thumbsDownButtonTapped
    case timeTick
    case virtualTimerButtonTapped
  }
  func reduce(into state:inout State,action:Action)->EffectTask<Action> {
    // fix up scores
    func updata(_ t:Bool) {
      let oc =  t ? ScoreDatum.ChallengeOutcomes.playedCorrectly : .playedIncorrectly
      state.scoreDatum.adjustScoresForTopic( state.challenge.topic, idx: 999, outcome:oc)
      state.showing = t ? .answerWasCorrect : .answerWasIncorrect
      state.isTimerRunning = false
    }
    switch action {
    case .answer1ButtonTapped:
      updata( state.challenge.correct == state.challenge.answers[0])
      return .cancel(id: CancelID.timer) // stop timer
    case .answer2ButtonTapped:
      updata( state.challenge.correct == state.challenge.answers[1])
      return .cancel(id: CancelID.timer)
    case .answer3ButtonTapped:
      updata( state.challenge.correct == state.challenge.answers[2])
      return .cancel(id: CancelID.timer)
    case .answer4ButtonTapped:
      updata( state.challenge.correct == state.challenge.answers[3])
      return .cancel(id: CancelID.timer)
    case .answer5ButtonTapped:
      updata( state.challenge.correct == state.challenge.answers[4])
      return .cancel(id: CancelID.timer)
      
    case .hintButtonTapped:
      if state.showing == .qanda {state.showing = .hint} // dont stop timer
      return .none
      
    case .timeTick:
      state.timerCount += 1
      return .none
      
    case .virtualTimerButtonTapped:
      state.isTimerRunning.toggle()
      if state.isTimerRunning {
        return .run { [ist = state.isTimerRunning ] send in
          while  ist  {
            try await Task.sleep(for: .seconds(1))
            await send(.timeTick)
          }
        }
        .cancellable(id: CancelID.timer)
      } else {
        return .cancel(id: CancelID.timer)
      }
      
    case .infoButtonTapped:    return .none
      
    case .thumbsUpButtonTapped:    return .none
      
    case .thumbsDownButtonTapped:    return .none
      
    }
  }
}

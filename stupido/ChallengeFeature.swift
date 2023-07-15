import ComposableArchitecture
import SwiftUI
import q20kshare

struct ChallengeView: View {
  
  struct ChallengeViewState: Equatable {
    let challenges: [Challenge]
    let showing: ChallengeFeature.State.Showing
    let timerCount: Int
    let questionNumber:Int
    let questionMax:Int
    let sd:ScoreDatum
    let thisChallenge:Challenge
    
     init(state: ChallengeFeature.State) {
       self.challenges = state.challenges
       self.showing = state.showing
       self.timerCount = state.timerCount
       self.questionMax = state.questionMax
       self.questionNumber = state.questionNumber
       self.sd = state.scoreDatum
       self.thisChallenge = state.challenges[state.questionNumber]
     }
   }
  
  let challengeStore:StoreOf<ChallengeFeature>

  var body: some View {
    //, removeDuplicates :==
    WithViewStore(challengeStore,observe: ChallengeViewState.init  ){viewStore in
    VStack{
        //let _ = print (viewStore.timerCount)
     // let challenges = viewStore.challenges
        VStack {
          HStack {
            Text("Grand Score \(viewStore.sd.grandScore)")
            Spacer()
            Text("\(viewStore.timerCount)")
            Spacer( )
            Text("Topic Score  \( viewStore.sd.scoresByTopic[  viewStore.thisChallenge.topic]?.topicScore ?? 0)")
          }.font(.footnote).padding(.horizontal)
        }
        Group {
          
          VStack {
            HStack {
              Text("Question \(viewStore.questionNumber)" + "/" + "\(viewStore.questionMax)")
              Spacer()
              Text("Topic \( viewStore.thisChallenge.topic)")
            }.font(.footnote)
            Text( viewStore.thisChallenge.question).font(.title)
          }
          .borderedStyleStrong(.gray)
          .padding()
    
          if viewStore.thisChallenge.answers.count>0 {
            Button(viewStore.thisChallenge.answers[0]){viewStore.send(.answer1ButtonTapped)}
              .borderedStyle(.gray)
          }
          if viewStore.thisChallenge.answers.count>1 {
            Button(viewStore.thisChallenge.answers[1]){viewStore.send(.answer2ButtonTapped)}
              .borderedStyle(.gray)
          }
          if viewStore.thisChallenge.answers.count>2 {
            Button(viewStore.thisChallenge.answers[2]){viewStore.send(.answer3ButtonTapped)}
              .borderedStyle(.gray)
          }
          if viewStore.thisChallenge.answers.count>3 {
            Button(viewStore.thisChallenge.answers[3]){viewStore.send(.answer4ButtonTapped)}
              .borderedStyle(.gray)
          }
          if viewStore.thisChallenge.answers.count>4 {
            Button(viewStore.thisChallenge.answers[4]){viewStore.send(.answer5ButtonTapped)}
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
            Text("Hint:" + viewStore.thisChallenge.hint).font(.headline)
          case .answerWasCorrect:
            Text("Answer: " + viewStore.thisChallenge.correct).font(.title)
              .borderedStyleStrong( .green)
            if viewStore.thisChallenge.opinions.count > 0 {
              let explanation = viewStore.thisChallenge.opinions[0].explanation
              Text(explanation)
                .borderedStyleStrong(.green)
            }
          case .answerWasIncorrect:
            Text("Answer: " + viewStore.thisChallenge.correct).font(.title)
              .borderedStyleStrong( .red)
            if viewStore.thisChallenge.opinions.count > 0 {
              let explanation = viewStore.thisChallenge.opinions[0].explanation
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
        viewStore.send(.virtualTimerButtonTapped)
      }
    }
  }
}

struct ChallengeView_Previews: PreviewProvider {
  static var previews: some View {
    let scoreDatum = ScoreDatum()
    ChallengeView(challengeStore: Store(initialState:ChallengeFeature.State( scoreDatum: scoreDatum,
            challenges:[SampleData.challenge1,SampleData.challenge2],        questionNumber:0, questionMax:1 ))
                  {  ChallengeFeature( )  }
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
    var challenges:[Challenge] = []

    var questionNumber:Int = 0
    var questionMax:Int = 0
    var showing:Showing = .qanda
    var isTimerRunning = false
    var timerCount = 0
    var topic : String {
      challenges[questionNumber].topic
    }
    
  }// end of state
  enum CancelID { case timer }
  enum Action {
    case nextButtonTapped
    case previousButtonTapped
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
  fileprivate func startTimer(_ state: inout ChallengeFeature.State) -> EffectTask<ChallengeFeature.Action> {
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
  }
  
  func reduce(into state:inout State,action:Action)->EffectTask<Action> {
    // fix up scores
    func updata(_ idx:Int) {
    let t =  state.challenges[state.questionNumber].correct == state.challenges[state.questionNumber].answers[idx]
      let oc =  t ? ScoreDatum.ChallengeOutcomes.playedCorrectly : .playedIncorrectly
      state.scoreDatum.adjustScoresForTopic( state.challenges[state.questionNumber].topic, idx: 999, outcome:oc)
      state.showing = t ? .answerWasCorrect : .answerWasIncorrect
      state.isTimerRunning = false
    }
    switch action {
    case .answer1ButtonTapped:
      updata(0)
      return .cancel(id: CancelID.timer) // stop timer
    case .answer2ButtonTapped:
      updata(1)
      return .cancel(id: CancelID.timer)
    case .answer3ButtonTapped:
      updata(2)
      return .cancel(id: CancelID.timer)
    case .answer4ButtonTapped:
      updata(3)
      return .cancel(id: CancelID.timer)
    case .answer5ButtonTapped:
      updata(4)
      return .cancel(id: CancelID.timer)
      
    case .hintButtonTapped:
      if state.showing == .qanda {state.showing = .hint} // dont stop timer
      return .none
      
    case .timeTick:
      state.timerCount += 1
      return .none
      
    case .virtualTimerButtonTapped:
      return startTimer(&state)
      
    case .infoButtonTapped:    return .none
      
    case .thumbsUpButtonTapped:    return .none
      
    case .thumbsDownButtonTapped:    return .none
      
    case .nextButtonTapped:
      if state.questionNumber < state.questionMax {
        state.questionNumber += 1
        state.timerCount = 0
        state.showing = .qanda
        return startTimer(&state)
        
      }
      return .none
      
    case .previousButtonTapped:
      if state.questionNumber > 0 {
        state.questionNumber -= 1
        state.timerCount = 0
        state.showing = .qanda
        return startTimer(&state)
      }
      return .none
      
    }
  }
}

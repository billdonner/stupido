import ComposableArchitecture
import SwiftUI
import q20kshare

struct ChallengeView: View {
  
  struct ViewState: Equatable {

     let challenge: Challenge
    let showing: ChallengeFeature.State.Showing
    let timerCount: Int
    // let unreadActivityCount: Int
     init(state: ChallengeFeature.State) {
       self.challenge = state.challenge
       self.showing = state.showing
       self.timerCount = state.timerCount
      // self.unreadActivityCount = state.activity.unreadCount
     }
   }
  
  let challengeStore:StoreOf<ChallengeFeature>
  let scoreDatum:ScoreDatum
  let questionNumber:Int
  let questionMax:Int
  var body: some View {
    //, removeDuplicates :==
    WithViewStore(challengeStore,observe: ViewState.init  ){viewStore in
    VStack{
        //let _ = print (viewStore.timerCount)
      let challenge = viewStore.challenge
        VStack {
          HStack {
            Text("Grand Score \(scoreDatum.grandScore)")
            Spacer()
            Text("\(viewStore.state.timerCount)")
            Spacer( )
            Text("Topic Score  \( scoreDatum.scoresByTopic[  challenge.topic]?.topicScore ?? 0)")
          }.font(.footnote).padding(.horizontal)
        }
        Group {
          
          VStack {
            HStack {
              Text("Question \(questionNumber)" + "/" + "\(questionMax)")
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
          switch viewStore.state.showing {
          case .qanda:
           // Button("Hint"){
              //viewStore.send(.hintButtonTapped)
           // }
            //break
            Text("Hint:" + challenge.hint).font(.headline)
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
          }.disabled(viewStore.state.showing == .hint || viewStore.state.showing == .qanda)
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
          }.disabled(viewStore.state.showing == .hint || viewStore.state.showing == .qanda)
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
    ChallengeView(challengeStore: Store(initialState:ChallengeFeature.State( )){
      ChallengeFeature( )
    }, scoreDatum: scoreDatum,
                  questionNumber: 1,
                  questionMax: 456)
  }
}
struct ChallengeFeature: ReducerProtocol {
//  let scoreDatum: ScoreDatum
//  let ch:Challenge
//  let idx:Int
  
  
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
    
    var challenge:Challenge = SampleData.challenge
    var idx:Int = 0
    var showing:Showing = .qanda
    var isTimerRunning = false
    var timerCount = 0
//    var topic : String {
//      challenge.topic
//    }
    
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
//     let oc =  t ? ScoreDatum.ChallengeOutcomes.playedCorrectly : .playedIncorrectly
////      state.scoreDatum.adjustScoresForTopic( state.challenge.topic, idx: 999, outcome:oc)
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
    case .infoButtonTapped: break
    case .thumbsUpButtonTapped: break
    case .thumbsDownButtonTapped: break
    case .timeTick:
      state.timerCount += 1
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
    }
    return .none // most cases end here
  }
}

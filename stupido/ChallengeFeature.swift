import ComposableArchitecture
import SwiftUI
import q20kshare

/** */
enum Showing:Equatable {
  case qanda
  case hint
  case answerWasCorrect
  case answerWasIncorrect
}
struct ChallengeFeature: ReducerProtocol {
  
  struct State : Equatable {
    
    internal init(topic:String = "", challenges: [Challenge] = [], questionNumber: Int = 0, showing: Showing = .qanda, isTimerRunning: Bool = false, timerCount: Int = 0) {
      self.topic = topic
      self.challenges = challenges
      self.questionNumber = questionNumber
      self.showing = showing
      self.isTimerRunning = isTimerRunning
      self.timerCount = timerCount
    }
 
    static func == (lhs: ChallengeFeature.State, rhs: ChallengeFeature.State) -> Bool {
      lhs.showing == rhs.showing
      && lhs.timerCount == rhs.timerCount
    }
    
    // present feature
    @PresentationState  var showInfoView: ShowInfoFeature.State?
    @PresentationState  var showThumbsUpView: ThumbsUpFeature.State?
    @PresentationState  var showThumbsDownView: ThumbsDownFeature.State?
    var scoresByTopic:[String:ScoreData] = [:]
    var topic:String = ""
    var challenges:[Challenge] = []
    var questionNumber:Int = 0
     
    var showing:Showing = .qanda
    var isTimerRunning = false
    var timerCount = 0
    
    var topics : [String] {
    scoresByTopic.map {$0.1.topic}
    }
    var topicScore : Int {
      if let sbt = scoresByTopic[topic] {
        return sbt.outcomes.reduce(0) { $0 + ($1 == .playedCorrectly ? 1:0)}
      }
      return 0
    }
    var grandScore : Int {
     scoresByTopic.reduce(0) { $0 + $1.1.playedCorrectly}
    }
    
    func dump() {
      for x in scoresByTopic
      {
        print (x.0,terminator:" ")
        print (x.1.outcomes.reduce(0) { $0 + ($1 == ChallengeOutcomes.playedCorrectly ? 1:0)})
      }
      print( grandScore)
    }
  }// end of state
  
  enum CancelID { case timer }
  
  enum Action:Equatable {
    case cancelButtonTapped
    case delegate(Delegate)
    enum Delegate:Equatable {
     // case cancel
    }
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
    case onceOnlyVirtualyTapped
    case showInfo(PresentationAction<ShowInfoFeature.Action>)
    case thumbsUp(PresentationAction<ThumbsUpFeature.Action>)
    case thumbsDown(PresentationAction<ThumbsDownFeature.Action>)
  }
  
  fileprivate func answerButtonTapped(_ state: inout ChallengeFeature.State,  _ idx:Int) {
    let thisChallenge = state.challenges[state.questionNumber]
    let t =  thisChallenge.correct == thisChallenge.answers[idx]
    var outcomes = state.scoresByTopic[state.topic]?.outcomes ?? Array(repeating:.unplayed,count:state.challenges.count)
    let oc =  t ? ChallengeOutcomes.playedCorrectly : .playedIncorrectly
    // if unplayed
    if outcomes [state.questionNumber] == ChallengeOutcomes.unplayed {
      // adjust the outcome
      outcomes [state.questionNumber] = oc
      state.scoresByTopic[state.topic] = ScoreData(topic:state.topic,outcomes: outcomes)
    }
    state.showing = t ? .answerWasCorrect : .answerWasIncorrect
    state.isTimerRunning = false
  }
  
  
  fileprivate func startTimer(_ state: inout ChallengeFeature.State) -> EffectTask<ChallengeFeature.Action> {
    return .none 
//    state.isTimerRunning = true
//    if state.isTimerRunning {
//      return .run { [ist = state.isTimerRunning ] send in
//        while  ist  {
//          try await Task.sleep(for: .seconds(1))
//          await send(.timeTick)
//        }
//      }
//      .cancellable(id: CancelID.timer)
//    } else {
//      return .cancel(id: CancelID.timer)
//    }
  }
  
  
  
  @Dependency(\.dismiss) var dismiss
  
 // func reduce(into state:inout State,action:Action)->EffectTask<Action> {
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      // fix up scores
      let thisChallenge = state.challenges[state.questionNumber]
      
      switch action {
      case .cancelButtonTapped:
        return .run { _ in await self.dismiss() }
      case .delegate:
        return .none
      case .answer1ButtonTapped:
        answerButtonTapped(&state, 0)
        return .cancel(id: CancelID.timer) // stop timer
      case .answer2ButtonTapped:
        answerButtonTapped(&state,1)
        return .cancel(id: CancelID.timer)
      case .answer3ButtonTapped:
        answerButtonTapped(&state,2)
        return .cancel(id: CancelID.timer)
      case .answer4ButtonTapped:
        answerButtonTapped(&state,3)
        return .cancel(id: CancelID.timer)
      case .answer5ButtonTapped:
        answerButtonTapped(&state,4)
        return .cancel(id: CancelID.timer)
        
      case .hintButtonTapped:
        if state.showing == .qanda {state.showing = .hint} // dont stop timer
        
      case .timeTick:
        state.timerCount += 1
      
      case .virtualTimerButtonTapped: return startTimer(&state)
        
      case .nextButtonTapped:
        if state.questionNumber < state.challenges.count  {
          state.questionNumber += 1
          state.timerCount = 0
          state.showing = .qanda
         // state.once = true
          return startTimer(&state)
        }
        
      case .previousButtonTapped:
        if state.questionNumber > 0 {
          state.questionNumber -= 1
          state.timerCount = 0
          state.showing = .qanda
         // state.once = true
          return startTimer(&state)
        }
        
      case .onceOnlyVirtualyTapped:
        state.questionNumber = 0
        state.timerCount = 0
        state.showing = .qanda
        //state.once = true
        return startTimer(&state)
        
        // these buttons present sheets when the ser taps
      case .infoButtonTapped:
        state.showInfoView = ShowInfoFeature.State(challenge:thisChallenge)
 
      case .thumbsUpButtonTapped:
        state.showThumbsUpView =  ThumbsUpFeature.State(challenge:thisChallenge)
 
      case .thumbsDownButtonTapped:
        state.showThumbsDownView = ThumbsDownFeature.State(challenge:thisChallenge)
         
      case .showInfo, .thumbsUp(_),.thumbsDown(_):
        return .none
        
      }
      // if we get this far
      return .none
    }
    .ifLet(\.$showInfoView,action:/Action.showInfo){
      ShowInfoFeature()
    }
    .ifLet(\.$showThumbsUpView,action:/Action.thumbsUp){
      ThumbsUpFeature()
    }
    .ifLet(\.$showThumbsDownView,action:/Action.thumbsDown){
      ThumbsDownFeature()
    }
  }
}

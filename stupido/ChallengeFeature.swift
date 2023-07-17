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
  struct State :Equatable{
    static func == (lhs: ChallengeFeature.State, rhs: ChallengeFeature.State) -> Bool {
      lhs.showing == rhs.showing
      && lhs.timerCount == rhs.timerCount
    }
    // present feature
    @PresentationState var showInfoView: ShowInfoFeature.State?
    @PresentationState var showThumbsUpView: ThumbsUpFeature.State?
    @PresentationState var showThumbsDownView: ThumbsDownFeature.State?
    // this is read only here but read/write upstream
    var challenges:[Challenge] = []
    var questionMax:Int { challenges.count }
    // read/write here , but read/write upstream
    var scoreDatum=ScoreDatum()
    var outcomes:[ScoreDatum.ChallengeOutcomes] = []
    var topicScore: Int {
      outcomes.reduce(0) { $0 + ($1 == .playedCorrectly ? 1 : 0)}
    }
    // these are really of no interest upstream
    var questionNumber:Int = 0
    var showing:Showing = .qanda
    var isTimerRunning = false
    var timerCount = 0
    var once = false
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
    case onceOnlyVirtualyTapped
    case showInfo(PresentationAction<ShowInfoFeature.Action>)
    case thumbsUp(PresentationAction<ThumbsUpFeature.Action>)
    case thumbsDown(PresentationAction<ThumbsDownFeature.Action>)
  }
  fileprivate func startTimer(_ state: inout ChallengeFeature.State) -> EffectTask<ChallengeFeature.Action> {
    state.isTimerRunning = true 
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
  
 // func reduce(into state:inout State,action:Action)->EffectTask<Action> {
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      let thisChallenge = state.challenges[state.questionNumber]
      // fix up scores
      func answerButtonTapped(_ idx:Int) {
        let t =  thisChallenge.correct == thisChallenge.answers[idx]
        let oc =  t ? ScoreDatum.ChallengeOutcomes.playedCorrectly : .playedIncorrectly
        // if unplayed
        if state.outcomes [state.questionNumber] == .unplayed {
          // adjust the outcome
          state.outcomes [state.questionNumber] =  oc
          // answer must be correct to adjust score
          if t {
            state.scoreDatum.adjustScoresForTopic( thisChallenge.topic, idx: state.questionNumber, outcome:oc)
          }
        }
        state.showing = t ? .answerWasCorrect : .answerWasIncorrect
        state.once = false
        state.isTimerRunning = false
      }
      
      
      switch action {
      case .answer1ButtonTapped:
        answerButtonTapped(0)
        return .cancel(id: CancelID.timer) // stop timer
      case .answer2ButtonTapped:
        answerButtonTapped(1)
        return .cancel(id: CancelID.timer)
      case .answer3ButtonTapped:
        answerButtonTapped(2)
        return .cancel(id: CancelID.timer)
      case .answer4ButtonTapped:
        answerButtonTapped(3)
        return .cancel(id: CancelID.timer)
      case .answer5ButtonTapped:
        answerButtonTapped(4)
        return .cancel(id: CancelID.timer)
        
      case .hintButtonTapped:
        if state.showing == .qanda {state.showing = .hint} // dont stop timer
        
      case .timeTick:
        state.timerCount += 1
      
      case .virtualTimerButtonTapped: return startTimer(&state)
        
      case .nextButtonTapped:
        if state.questionNumber < state.questionMax {
          state.questionNumber += 1
          state.timerCount = 0
          state.showing = .qanda
          state.once = true
          return startTimer(&state)
        }
        
      case .previousButtonTapped:
        if state.questionNumber > 0 {
          state.questionNumber -= 1
          state.timerCount = 0
          state.showing = .qanda
          state.once = true
          return startTimer(&state)
        }
        
      case .onceOnlyVirtualyTapped:
        state.questionNumber = 0
        state.timerCount = 0
        state.showing = .qanda
        state.once = true
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

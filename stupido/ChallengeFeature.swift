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
    @PresentationState var showInfoView: ShowInfoFeature.State?
    
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
  
  func reduce(into state:inout State,action:Action)->EffectTask<Action> {
    // fix up scores
    func updata(_ idx:Int) {
      let t =  state.challenges[state.questionNumber].correct == state.challenges[state.questionNumber].answers[idx]
      
      let oc =  t ? ScoreDatum.ChallengeOutcomes.playedCorrectly : .playedIncorrectly
      // if unplayed
      if state.outcomes [state.questionNumber] == .unplayed {
        // adjust the outcome
        state.outcomes [state.questionNumber] =  oc
        // answer must be correct to adjust score
        if t {
          state.scoreDatum.adjustScoresForTopic( state.challenges[state.questionNumber].topic, idx: state.questionNumber, outcome:oc)
        }
      }
      state.showing = t ? .answerWasCorrect : .answerWasIncorrect
      state.once = false
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
      
      
    case .nextButtonTapped:
      if state.questionNumber < state.questionMax {
        state.questionNumber += 1
        state.timerCount = 0
        state.showing = .qanda
        state.once = true
        return startTimer(&state)
        
      }
      return .none
      
    case .previousButtonTapped:
      if state.questionNumber > 0 {
        state.questionNumber -= 1
        state.timerCount = 0
        state.showing = .qanda
        state.once = true
        return startTimer(&state)
      }
      return .none
      
      
    case .onceOnlyVirtualyTapped:
      state.questionNumber = 0
      state.timerCount = 0
      state.showing = .qanda
      state.once = true
      return startTimer(&state)
      
      // these buttons present sheets when the ser taps
    case .infoButtonTapped:    return .none
      
    case .thumbsUpButtonTapped:    return .none
      
    case .thumbsDownButtonTapped:    return .none
      
    case .showInfo:
      return .none
    }
  }
}

    .ifLet(\.$showInfo,action:/Action.showInfo){
      ShowInfoFeature()
    }
}

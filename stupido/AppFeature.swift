import ComposableArchitecture
import SwiftUI
import q20kshare

/** */

struct XAppFeature: ReducerProtocol {
  struct State :Equatable{
    static func == (lhs: AppFeature.State, rhs: AppFeature.State) -> Bool {
      lhs.showing == rhs.showing
      && lhs.timerCount == rhs.timerCount
     // &&  lhs.gameDatum == rhs.gameDatum
      
    }
    
    var isLoading = false // is gamedata loading
    var gameDatum : [GameData] = []
    var scoreDatum =  ScoreDatum.reloadOrInit ()
    
    
    // present feature
//    @PresentationState var showInfoView: ShowInfoFeature.State?
//    @PresentationState var showThumbsUpView: ThumbsUpFeature.State?
//    @PresentationState var showThumbsDownView: ThumbsDownFeature.State?
    

    
    // this is read only here but read/write upstream
    var challenges:[Challenge] = []
    var questionMax:Int { challenges.count }
    // read/write here , but readonly upstream
   // var scoreDatum=ScoreDatum()
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
//    case nextButtonTapped
//    case previousButtonTapped
//    case answer1ButtonTapped
//    case answer2ButtonTapped
//    case answer3ButtonTapped
//    case answer4ButtonTapped
//    case answer5ButtonTapped
//    case hintButtonTapped
//    case infoButtonTapped
//    case thumbsUpButtonTapped
//    case thumbsDownButtonTapped
//    case timeTick
//    case virtualTimerButtonTapped
//    case onceOnlyVirtualyTapped
    case reloadButtonTapped
    case reloadButtonResponse([GameData])
//    case showInfo(PresentationAction<ShowInfoFeature.Action>)
//    case thumbsUp(PresentationAction<ThumbsUpFeature.Action>)
//    case thumbsDown(PresentationAction<ThumbsDownFeature.Action>)
  }
//  fileprivate func startTimer(_ state: inout AppFeature.State) -> EffectTask<AppFeature.Action> {
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
//  }
  
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
//      case .answer1ButtonTapped:
//        answerButtonTapped(0)
//        return .cancel(id: CancelID.timer) // stop timer
//      case .answer2ButtonTapped:
//        answerButtonTapped(1)
//        return .cancel(id: CancelID.timer)
//      case .answer3ButtonTapped:
//        answerButtonTapped(2)
//        return .cancel(id: CancelID.timer)
//      case .answer4ButtonTapped:
//        answerButtonTapped(3)
//        return .cancel(id: CancelID.timer)
//      case .answer5ButtonTapped:
//        answerButtonTapped(4)
//        return .cancel(id: CancelID.timer)
//        
//      case .hintButtonTapped:
//        if state.showing == .qanda {state.showing = .hint} // dont stop timer
//        
//      case .timeTick:
//        state.timerCount += 1
//      
//      case .virtualTimerButtonTapped: return startTimer(&state)
//        
//      case .nextButtonTapped:
//        if state.questionNumber < state.questionMax {
//          state.questionNumber += 1
//          state.timerCount = 0
//          state.showing = .qanda
//          state.once = true
//          return startTimer(&state)
//        }
//        
//      case .previousButtonTapped:
//        if state.questionNumber > 0 {
//          state.questionNumber -= 1
//          state.timerCount = 0
//          state.showing = .qanda
//          state.once = true
//          return startTimer(&state)
//        }
//        
//      case .onceOnlyVirtualyTapped:
//        state.questionNumber = 0
//        state.timerCount = 0
//        state.showing = .qanda
//        state.once = true
//        return startTimer(&state)
        
        // these buttons present sheets when the ser taps
//      case .infoButtonTapped:
//        state.showInfoView = ShowInfoFeature.State(challenge:thisChallenge)
// 
//      case .thumbsUpButtonTapped:
//        state.showThumbsUpView =  ThumbsUpFeature.State(challenge:thisChallenge)
// 
//      case .thumbsDownButtonTapped:
//        state.showThumbsDownView = ThumbsDownFeature.State(challenge:thisChallenge)
      case let .reloadButtonResponse(gameData):
          state.gameDatum = gameData
          state.isLoading = false
          state.scoreDatum.setScoresFromGameData(gameData)
        print("Data loaded \(gameData.count) topics")
      case .reloadButtonTapped:
        if !state.isLoading {
        state.gameDatum = []
        state.isLoading = true
        return .run { //[count = state.count]
          send in
          let count = 1
          let (data, _) = try await URLSession.shared
            .data(from: URL(string: "https://billdonner.com/fs/gs/readyforios\(count)")!)
          let gd = try JSONDecoder().decode([GameData].self,from:data)
          await send(.reloadButtonResponse(gd))
        }
      }
         
//      case .showInfo, .thumbsUp(_),.thumbsDown(_):
//        return .none
        
//      case .infoButtonTapped:
//        <#code#>
//      case .thumbsUpButtonTapped:
//        <#code#>
//      case .thumbsDownButtonTapped:
//        <#code#>
     }
      // if we get this far
      return .none
    }
//    .ifLet(\.$showInfoView,action:/Action.showInfo){
//      ShowInfoFeature()
//    }
//    .ifLet(\.$showThumbsUpView,action:/Action.thumbsUp){
//      ThumbsUpFeature()
//    }
//    .ifLet(\.$showThumbsDownView,action:/Action.thumbsDown){
//      ThumbsDownFeature()
//    }
  }
}

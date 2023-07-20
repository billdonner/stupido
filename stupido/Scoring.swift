//
//  Scoring.swift
//  tcaqa
//
//  Created by bill donner on 7/11/23.
//

import Foundation
import q20kshare


struct ScoreDatum :Equatable {

  enum ChallengeOutcomes :Codable ,Equatable{
    case unplayed
    case playedCorrectly
    case playedIncorrectly
  }
  struct ScoreData : Codable,Equatable {
    let topic:String
    let topicScore:Int
    let outcomes:[ChallengeOutcomes]
    
    var highWaterMark : Int {
      outcomes.reduce(0){x,y in x + ((y != .unplayed) ? 1 : 0)}
    }
    var playedCorrectly : Int {
      outcomes.reduce(0){x,y in x + ((y == .playedCorrectly) ? 1 : 0)}
    }
    var playedInCorrectly : Int {
      outcomes.reduce(0){x,y in x + ((y == .playedIncorrectly) ? 1 : 0)}
    }
  }
  
  
  internal init(scoresByTopic: [String : ScoreData] = [String:ScoreData]()) {
    self.scoresByTopic = scoresByTopic
  }
  // this is the only real data up here
 // @Published
  var scoresByTopic = [String:ScoreData]()
  
  // computed
  var grandScore : Int {
    var gs = 0
    for (_,b) in scoresByTopic  {
      gs += b.topicScore
    }
    return gs
  }
  
  func save(){
    // can not save whole class because its an Observable Object and isnt Codable
    let encoder = JSONEncoder()
    if let encoded  = try? encoder.encode(self.scoresByTopic) {
      let defaults = UserDefaults.standard
      defaults.set(encoded, forKey: "ScoreDatum")
    }
  }
   private static func restore() -> [String : ScoreData]? {
    let defaults = UserDefaults.standard
    if let savedData = defaults.object(forKey: "ScoreDatum") as? Data {
      let decoder = JSONDecoder()
      if let dictionary = try? decoder.decode([String : ScoreData].self, from: savedData) {
        return dictionary
      }
    }
    return nil
  }
  static func reloadOrInit()->ScoreDatum {
    let s = ScoreDatum.restore()
    if let dict = s {
      return ScoreDatum(scoresByTopic: dict)
    }
    return ScoreDatum()
  }
  
  mutating func adjustScoresForTopic(_ topic:String,idx:Int, outcome:ChallengeOutcomes,by n:Int=1) {
    let x = scoresByTopic[topic]
    guard let x = x else {return}
    var cha = x.outcomes
    cha[idx] = outcome
    scoresByTopic[topic] = ScoreData(topic:topic,
                                     topicScore: x.topicScore + n, outcomes:cha)
    save()
    
  }
  mutating func setScoresFromGameData(_ gameData:[GameData]) {
    scoresByTopic = [:]
    for gd in gameData {
      scoresByTopic[gd.subject]=ScoreData(topic:gd.subject,
                                          topicScore: 0,
                                          outcomes:Array(repeating: ChallengeOutcomes.unplayed,
                                            count: gd.challenges.count))
    }
    save()
  }
}

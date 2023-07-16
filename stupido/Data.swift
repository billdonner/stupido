//
//  Data.swift
//  stupido
//
//  Created by bill donner on 7/12/23.
//
 
import q20kshare


struct SampleData { 
  static let outcomes:[ScoreDatum.ChallengeOutcomes] = [.playedCorrectly,.unplayed]
  
  static let scoresByTopic =  ["Nature":ScoreDatum.ScoreData(topic:"Nature",topicScore: 1,highWaterMark: -1,outcomes: outcomes)]
  
  static let scoreDatum = ScoreDatum(scoresByTopic:scoresByTopic)
  
  static let opinions = [
    Opinion(id: "1234-5678-91011", truth: false, explanation: "blah blah blah blah blah blah blah blah", opinionID: "9999999", source: "billbot-070-v2"),
    Opinion(id: "932823-abcd0393-11", truth: true, explanation: "blah blah blah blah blah blah blah blah", opinionID: "9999998", source: "bard-023-v3")
  ]
  static let challenge1 = Challenge(question: "Why is the sky blue?", topic: "Nature", hint: "It's not green", answers: ["good","bad","ugly"], correct: "good",id:"aa849-2339-23bcd", opinions:opinions)
  
  static let challenge2 = Challenge(question: "Why is water blue?", topic: "Nature", hint: "It's not red", answers: ["red","yellow","green"], correct: "yellow",id:"aa777-2339-23bcd", opinions:opinions)
  
  static let challenges = [challenge1,challenge2]
  

}

//
//  Data.swift
//  stupido
//
//  Created by bill donner on 7/12/23.
//
 
import q20kshare


struct SampleData {

  static let outcomes:[ ChallengeOutcomes] = [.unplayed,.playedCorrectly]
  
  static let scoresByTopic =  ["Nature": ScoreData(topic:"Nature",outcomes: outcomes)]
  
 // static let scoreDatum = ScoreDatum(scoresByTopic:scoresByTopic)
  
  static let opinions = [
    Opinion(id: "1234-5678-91011", truth: false, explanation: "This is chatgpt's explanation", opinionID: "9999999", source: "billbot-070-v2"),
    Opinion(id: "932823-abcd0393-11", truth: true, explanation: "This is bard's explanation", opinionID: "9999998", source: "bard-023-v3")
  ]
  
  static let prompt1 = "Make up some fun questions for me"
  static let challenge1 = Challenge(question: "Why is the sky blue?", topic: "Nature", hint: "It's not green", answers: ["good","bad","ugly"], correct: "good", id:"aa849-2339-23bcd", source:"billbotv.2", prompt:prompt1, opinions:opinions)
  
  static let prompt2 = "Make up some hard questions for me"
  static let challenge2 = Challenge(question: "Why is water blue?", topic: "Nature", hint: "It's not red", answers: ["red","yellow","green"], correct: "yellow",id:"aa777-2339-23bcd", source:"billbotv.2", prompt:prompt2, opinions:opinions)
  
  static let challenges = [challenge1,challenge2]
  

}

//
//  Data.swift
//  stupido
//
//  Created by bill donner on 7/12/23.
//
 
import q20kshare


struct SampleData {
  static let opinions = [
    Opinion(id: "1234-5678-91011", truth: false, explanation: "blah blah blah blah blah blah blah blah", opinionID: "9999999", source: "billbot-070-v2"),
    Opinion(id: "932823-abcd0393-11", truth: true, explanation: "blah blah blah blah blah blah blah blah", opinionID: "9999998", source: "bard-023-v3")
  ]
  static let challenge = Challenge(question: "Why is the sky blue?", topic: "Nature", hint: "It's not green", answers: ["good","bad","ugly"], correct: "good",id:"aa849-2339-23bcd", opinions:opinions)

}

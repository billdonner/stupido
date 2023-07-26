//
//  Expertise.swift
//  stupido
//
//  Created by bill donner on 7/15/23.
//
//
// Labels and All Math Subject to Change

import SwiftUI
import ComposableArchitecture
import q20kshare

enum Expertise: String, Equatable {
  case novice = "It's a start"
  case interested = "Good"
  case knowledgeable = "Impressive"
  case expert = "Terrific"
}
  
 func calculateExpertise(_ outcomes:[ChallengeOutcomes]) -> Expertise {
    let topicScore = outcomes.reduce(0){x,y in
     x + (y == ChallengeOutcomes.playedCorrectly  ? 1 : 0)}

    let pct:Double = Double(topicScore) / Double(outcomes.count)
  
    let expertise:Expertise = switch pct {
    case 0.0..<0.25: .novice
    case 0.25..<0.50:.interested
    case 0.50..<0.75:.knowledgeable
    case 0.75...1.0: .expert
    default:
        .novice
    }
    let _ = print("topicScore \(topicScore) outcomes.count \(outcomes.count), [0] \(outcomes[0]) pct \(pct) expertise \(expertise)")
    return expertise
  }

struct ExpertiseView : View {
  let outcomes:[ChallengeOutcomes]
  var body: some View {
    
    let expertise =  calculateExpertise(outcomes)
    HStack {
      Text(Expertise.novice.rawValue).opacity(expertise == .novice ? 1 : 0.5)
      Spacer()
      Text(Expertise.interested.rawValue).opacity(expertise == .interested ? 1 : 0.5)
      Spacer()
      Text(Expertise.knowledgeable.rawValue).opacity(expertise == .knowledgeable ? 1 : 0.5)
      Spacer()
      Text(Expertise.expert.rawValue).opacity(expertise == .expert ? 1 : 0.5)
    }
  }
}

struct ExpertiseView_Previews: PreviewProvider {
  static var previews: some View {
    ExpertiseView(outcomes: [.playedCorrectly,.playedCorrectly]).padding()
  }
}

//
//  Expertise.swift
//  stupido
//
//  Created by bill donner on 7/15/23.
//

import SwiftUI
import ComposableArchitecture
import q20kshare

enum Expertise: String, Equatable {
  case novice
  case interested
  case knowledgeable
  case expert
}

struct ExpertiseView : View {
  let outcomes:[ScoreDatum.ChallengeOutcomes]
  var body: some View {
    let topicScore = outcomes.reduce(0){$0
      +
      ($1 == .playedCorrectly ? 1 : 0)}
    
    
    let pct:Double = Double(topicScore / outcomes.count)
    let expertise:Expertise = switch pct {
    case 0.0..<0.25: .novice
    case 0.25..<0.50:.knowledgeable
    case 0.75..<1.0: .expert
    default:
        .novice
    }
    
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
    ExpertiseView(outcomes: SampleData.outcomes).padding()
  }
}

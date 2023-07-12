//
//  ChallengeFeatureTests.swift
//  tcaqa
//
//  Created by bill donner on 7/12/23.
//

import ComposableArchitecture
import XCTest
@testable import stupido


@MainActor
final class ChallengeFeatureTests: XCTestCase {
  func testCounter() async {
    let scoreDatum = ScoreDatum()
    let store = TestStore(initialState: ChallengeFeature.State()) {
      ChallengeFeature(scoreDatum: scoreDatum, ch: SampleData.challenge, idx: 0)
    }

    await store.send(.hintButtonTapped){
      $0.showing = .hint
    }
    await store.send(.answer1ButtonTapped){
      $0.showing = .answerWasCorrect // really needs to be true
    }
    await store.send(.answer2ButtonTapped){
      $0.showing = .answerWasIncorrect// really needs to be true
    }
    await store.send(.hintButtonTapped){
      $0.showing = .hint // really needs to be true
    }
  }
}

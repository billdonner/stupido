//
//  InfoFeature.swift
//  stupido
//
//  Created by bill donner on 7/16/23.
//

import ComposableArchitecture
import q20kshare
import SwiftUI


struct ShowInfoView: View {
  let store: StoreOf<ShowInfoFeature>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
       Text("BleeBlah")
      }
      .toolbar {
        ToolbarItem {
          Button("Cancel") {
            viewStore.send(.cancelButtonTapped)
          }
        }
      }
    }
  }
}
struct ShowInfoPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ShowInfoView(
        store: Store(
          initialState: ShowInfoFeature.State(
            challenge: SampleData.challenge1
          ),
          reducer: ShowInfoFeature()
        )
      )
    }
  }
}
struct ShowInfoFeature: ReducerProtocol {
  struct State: Equatable {
    var challenge: Challenge
  }
  enum Action: Equatable {
    case cancelButtonTapped
  }
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .cancelButtonTapped:
      return .none

    }
  }
}

//
//  ThumbsDownFeature.swift
//  stupido
//
//  Created by bill donner on 7/16/23.
//

import ComposableArchitecture
import q20kshare
import SwiftUI

struct ThumbsDownView: View {
  let store: StoreOf<ThumbsDownFeature>
  @State private var isOn0 = false
  @State private var isOn1 = false
  @State private var isOn2 = false
  @State private var isOn3 = false
  @State private var freeForm = ""
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      let challenge = viewStore.challenge
      NavigationStack{
        Form {
          Section {
            Text(challenge.question).foregroundStyle(.red).font(.headline)
            Text("Sorry you didn't like this Challenge.  Please let us know why you disliked it . Select all that apply:").padding([.top,.bottom])
          }
          Section {
            Toggle(isOn: $isOn0) {
              Text("It is inaccurate")
            }.toggleStyle(.switch)
            Toggle(isOn: $isOn1) {
              Text("It is too easy")
            }.toggleStyle(.switch)
            Toggle(isOn: $isOn2) {
              Text("It is too hard")
            }.toggleStyle(.switch)
            Toggle(isOn: $isOn3) {
              Text("It is irrelevant to the topic")
            }.toggleStyle(.switch)
          }
          Section {
            Text("If you'd like to communicate your thoughts directly, please enter them here:").padding([.top])
            TextField("don't be shy", text: $freeForm,axis:.vertical)
              .textFieldStyle(.roundedBorder)
          }
        }.padding([.top])
          .navigationBarItems(trailing:     Button {
            // send upstream
            viewStore.send(.cancelButtonTapped)
          } label: {
            Text("Submit")
          })
          .navigationBarItems(leading:     Button {
            viewStore.send(.cancelButtonTapped)
          } label: {
            Text("Cancel")
          })
          .navigationTitle("Thumbs Down")
      }
    }
  }
}

struct ThumbsDownPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ThumbsDownView(
        store: Store(
          initialState: ThumbsDownFeature.State(
            challenge: SampleData.challenge1
          ),
          reducer: ThumbsDownFeature()
        )
      )
    }
  }
}
struct ThumbsDownFeature: ReducerProtocol {
  struct State: Equatable {
    var challenge: Challenge
  }
  enum Action: Equatable {
    case cancelButtonTapped
    case delegate(Delegate)
    enum Delegate:Equatable {
     // case cancel
    }
  }
  @Dependency(\.dismiss) var dismiss
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .cancelButtonTapped:
      return .run { _ in await self.dismiss() }
    case .delegate:
      return .none

    }
  }
}

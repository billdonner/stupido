//
//  ThumbsUpFeature.swift
//  stupido
//
//  Created by bill donner on 7/16/23.
//

import ComposableArchitecture
import q20kshare
import SwiftUI

struct ThumbsUpView: View {
  let store: StoreOf<ThumbsUpFeature>
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
            Text(challenge.question).foregroundStyle(.blue).font(.headline)
            Text("Glad you enjoyed this Challenge. Please let us know why you liked it. Select all that apply:").padding([.top,.bottom])
          }
          Section {
            Toggle(isOn: $isOn0) {
              Text("It was clever")
            }.toggleStyle(.switch)
            Toggle(isOn: $isOn1) {
              Text("It was easy")
            }.toggleStyle(.switch)
            Toggle(isOn: $isOn2) {
              Text("It was hard")
            }.toggleStyle(.switch)
            Toggle(isOn: $isOn3) {
              Text("It was mind-bening")
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
          .navigationTitle("Thumbs Up")
      }
    }
  }
}

struct ThumbsUpPreviews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ThumbsUpView(
        store: Store(
          initialState: ThumbsUpFeature.State(
            challenge: SampleData.challenge1
          ),
          reducer: ThumbsUpFeature()
        )
      )
    }
  }
}
struct ThumbsUpFeature: ReducerProtocol {
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

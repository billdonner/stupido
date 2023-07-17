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
      let challenge = viewStore.challenge
      NavigationStack{
        ScrollView {
          VStack(spacing:20){
            HStack{ Text("The Challenge Generated By Chatbot")
              Spacer()
            }.font(.headline)
            VStack(spacing:5){
              HStack{
                Text("challenge id:")
                Spacer()
                Text(challenge.id )
              }
              HStack{
                Text("source:")
                Spacer()
                Text( challenge.aisource )
              }
              HStack{
                Text("generated:")
                Spacer()
                Text(challenge.date.formatted())
              }
              HStack{
                Text("topic:")
                Spacer()
                Text(challenge.topic)
              }
              HStack{
                Text("question:")
                Spacer()
                Text(challenge.question).font(.headline)
              }
              HStack{
                Text("answer:")
                Spacer()
                Text(challenge.correct).font(.headline)
              }
              if let img = challenge.image {
                HStack{
                  Text("image:")
                  Spacer()
                  Text(img).font(.headline)
                }
              }
              if let article = challenge.article {
                HStack{
                  Text("article:")
                  Spacer()
                  Text(article).font(.headline)
                }
              }
              // next one is over limit
              //          if let explanation = challenge.explantion {
              //            HStack{
              //              Text("explanation:")
              //              Spacer()
              //              Text(explanation).font(.headline)
              //            }
              //          }
              //
            }
            HStack{
              Text("Veracity Opinions From Other Chatbots").font(.headline)
              Spacer()
            }.font(.headline)
            VStack(spacing:5){
              ForEach(challenge.opinions) { opinion in
                HStack{
                  Text("source:")
                  Spacer()
                  Text( opinion.source )
                }
                HStack{
                  Text("opinion:")
                  Spacer()
                  Text(opinion.truth ? "true":"false").font(.headline)
                }
                HStack{
                  Text("explanation:")
                  Spacer()
                  Text(opinion.explanation)
                }
                Spacer(minLength: 10)
              }
              
            }
            HStack{
              Text("Prompt sent to ChatBot")
              Spacer()
            }.font(.headline)
            VStack(spacing:5){
              Text(decodeStringFromJSON(encodedString: challenge.prompt))
            }
          }.padding()
        }.navigationTitle("Challenge Details")
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

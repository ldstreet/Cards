//
//  ContentView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/27/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Models

enum App {
    
    struct Environment {
        
    }
}

struct AppView: View {
    
    struct State: Equatable {
        
    }
    
    struct Action {
        
    }
    
    let store: Store<App.State, App.Action>
    
    init(store: Store<App.State, App.Action>) {
        self.store = store
    }
    
    var body: some View {
        TabView{
            cardsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                        .font(.title)
                        .padding()
                }
            
            Text("Create Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .padding()
                        .clipShape(Circle())
                        .background(Color.red)
                        
                }
            
            Text("App Settings")
                .tabItem {
                    Image(systemName: "gear")
                        .font(.title)
                        .padding()
                }
        }
     
    }
    
    func cardsView() -> some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Cards.CardsView(
                        store: self.store.scope(
                            state: \.cardsState,
                            action: App.Action.cards
                        )
                    )
                    .navigationBarTitle("My Cards")
                    .navigationBarItems(
                       leading: EditButton(),
                       trailing: Button(
                           action: { viewStore.send(.showCreateCard(CreateCard.State())) },
                           label: { Image(systemName: "plus").font(.title) }
                       )
                    )
                    
                    Text("hi")
                        .frame(width: 0, height: 0, alignment: .center)
                        .sheet(
                            item: viewStore.binding(
                                get: \.createCardState,
                                send: App.Action.showCreateCard
                            ),
                            onDismiss: {
                                viewStore.send(.confirmCreateCardCancel(viewStore.createCardState?.card))
                            },
                            content: { _ in
                                IfLetStore(
                                    self.store.scope(
                                        state: \.createCardState,
                                        action: { return .create($0) }
                                    ),
                                    then: CreateCard.View.init
                                )
                            }
                        )
                }
            }
            
             .actionSheet(
                 item: viewStore.binding(
                    get: \.showCreateCardCancelDialog,
                    send: App.Action.confirmCreateCardCancel
                 ),
                 content: { canceledCard in
                     ActionSheet(
                         title: Text("Are you shure you want to discard this new business card?"),
                         buttons: [
                             .destructive(Text("Discard Changes")) {
                                 viewStore.send(.create(.cancel))
                             },
                             .default(Text("Keep Editing")) {
                                viewStore.send(.showCreateCard(CreateCard.State(card: canceledCard)))
                             }
                         ]
                     )
                 }
            )
        }
    }
}

extension AppView.State {
    init(_ state: App.State) {
        
    }
    
}

extension App.Action {
    init(_ action: AppView.Action) {
        switch action {
        default:
            self = .cards(.delete(.init()))
        }
    }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: .init(cardsState: .init(cards: .all)),
                reducer: App.reducer.cardsIO(),
                environment: .init()
            )
        )
    }
}
#endif

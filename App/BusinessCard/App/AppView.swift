//
//  ContentView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/27/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux
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
    @ObservedObject var viewStore: ViewStore<App.State, App.Action>
    
    init(store: Store<App.State, App.Action>) {
        self.store = store
        self.viewStore = store
//            .scope(
//                value: State.init,
//                action: App.Action.init
//            )
            .view
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
        NavigationView {
            VStack {
                IfLet(viewStore.value.cardsState) { cardsState in
                     Cards.CardsView(
                        store: self.store.scope(
                            value: { $0.cardsState },
                            action: { return .cards($0) }
                         )
                     )
                 }
                 .navigationBarTitle("My Cards")
                 .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: { self.viewStore.send(.showCreateCard(CreateCard.State())) },
                        label: { Image(systemName: "plus").font(.title) }
                    )
                )
                
                Text("hi")
                    .frame(width: 0, height: 0, alignment: .center)
                    .sheet(
                        item: viewStore.send(
                            App.Action.showCreateCard,
                            binding: \App.State.createCardState
                        ),
                        onDismiss: {
                            self.viewStore.send(.confirmCreateCardCancel(self.viewStore.value.createCardState?.card))
                        },
                        content: { _ in
                            self.store.scope(
                                value: { $0.createCardState },
                                action: { return .create($0) }
                            ).map(CreateCard.View.init)
                        }
                    )
            }
            
             
        }
        
         .actionSheet(
             item: viewStore.send(
                 App.Action.confirmCreateCardCancel,
                 binding: \.showCreateCardCancelDialog
             ),
             content: { canceledCard in
                 ActionSheet(
                     title: Text("Are you shure you want to discard this new business card?"),
                     buttons: [
                         .destructive(Text("Discard Changes")) {
                             self.viewStore.send(.create(.cancel))
                         },
                         .default(Text("Keep Editing")) {
                            self.viewStore.send(.showCreateCard(CreateCard.State(card: canceledCard)))
                         }
                     ]
                 )
             }
        )
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
                initialValue: .init(cardsState: .init(cards: .all)),
                reducer: logging(navigation(cardsIO(App.reducer))),
                environment: .init()
            )
        )
    }
}
#endif

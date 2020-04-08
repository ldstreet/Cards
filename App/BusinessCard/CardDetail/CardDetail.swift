//
//  CardDetail.swift
//  BusinessCard
//
//  Created by Luke Street on 10/29/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Models
import Redux

enum CardDetail {
    struct Environment {
        
    }
}

struct CardDetailView: View {
    
    private let store: Store<CardDetail.State, CardDetail.Action>
    @ObservedObject var viewStore: ViewStore<CardDetail.State, CardDetail.Action>
    
    init(store: Store<CardDetail.State, CardDetail.Action>) {
        self.store = store
        self.viewStore = store.view
    }
    
    var body: some View {
        VStack {
            header
            fields
            HStack {
                Text("Share")
                .foregroundColor(Color.white)
                .padding()
                .highPriorityGesture(TapGesture().onEnded {
                    self.viewStore.send(.share(self.viewStore.value.card))
                })
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.secondary)
                    .frame(width: 1, height: 20, alignment: .center)
                
                Text("Edit")
                    .foregroundColor(Color.white)
                    .padding()
                    .highPriorityGesture(TapGesture().onEnded {
                        self.viewStore.send(.edit(self.viewStore.value.card))
                    })
            }
            .background(Color.gray)
            .clipShape(Capsule())
            
        }
        .animation(.default)
        .padding()
    }
    
    var header: some View {
        VStack(alignment: .center) {
            ProfileImageHeader()
            Text(viewStore.value.card.name)
                .font(.largeTitle)
            Text(viewStore.value.card.title)
        }
    }
    
    var fields: some View {
        ForEach(0..<viewStore.value.card.groups.count) { groupIndex in
            ForEach(0..<self.viewStore.value.card.groups[groupIndex].fields.count) { fieldIndex in
                Text(self.viewStore.value.card.groups[groupIndex].fields[fieldIndex].value)
            }
        }
    }
}


#if DEBUG
struct CardDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardDetailView(
                store: .init(initialValue: CardDetail.State(card: .luke), reducer: CardDetail.reducer, environment: .init())
            )
                .previewLayout(.sizeThatFits)
            
            CardDetailView(
                store: .init(initialValue: CardDetail.State(card: .luke), reducer: CardDetail.reducer, environment: .init())
            )
                .previewLayout(.sizeThatFits)
        }
        
    }
}
#endif

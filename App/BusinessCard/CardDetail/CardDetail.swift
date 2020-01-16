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

enum CardDetail {}

struct CardDetailView: View {
    
    @ObservedObject var store: Store<CardDetail.State, CardDetail.Action>

    
    var body: some View {
        VStack {
            header
            fields
            HStack {
                Text("Share")
                .foregroundColor(Color.white)
                .padding()
                .highPriorityGesture(TapGesture().onEnded {
                    self.store.send(.share(self.store.value.card))
                })
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.secondary)
                    .frame(width: 1, height: 20, alignment: .center)
                
                Text("Edit")
                    .foregroundColor(Color.white)
                    .padding()
                    .highPriorityGesture(TapGesture().onEnded {
                        self.store.send(.edit(self.store.value.card))
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
            (
                Text(store.value.card.firstName) +
                Text(" ") +
                Text(store.value.card.lastName)
            )
                .font(.largeTitle)
            Text(store.value.card.title)
        }
    }
    
    var fields: some View {
        ForEach(0..<store.value.card.groups.count) { groupIndex in
            ForEach(0..<self.store.value.card.groups[groupIndex].fields.count) { fieldIndex in
                Text(self.store.value.card.groups[groupIndex].fields[fieldIndex].value)
            }
        }
    }
}


#if DEBUG
struct CardDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardDetailView(
                store: .init(initialValue: CardDetail.State(card: .luke), reducer: CardDetail.reducer)
            )
                .previewLayout(.sizeThatFits)
            
            CardDetailView(
                store: .init(initialValue: CardDetail.State(card: .luke), reducer: CardDetail.reducer)
            )
                .previewLayout(.sizeThatFits)
        }
        
    }
}
#endif

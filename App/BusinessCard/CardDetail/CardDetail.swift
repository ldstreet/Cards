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
//        .sheet(item: store.send(
//            CardDetail.Action.presentShareLink,
//            binding: \CardDetail.State.shareLink
//        )) {  url in
//            ActivityView(activityItems: [url.absoluteString], applicationActivities: nil)
//        }
    }
    
    var header: some View {
        VStack(alignment: .center) {
            ProfileImageHeader()//.transition(.opacity)
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
        ForEach(store.value.card.fields.groups.enumeratedArray(), id: \.offset) { fieldGroup in
            Section {
                ForEach(fieldGroup.element.fields.enumeratedArray(), id: \.offset) { field in
                    Text(field.element.value)
                }
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

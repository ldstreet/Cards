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
                    self.store.send(.share(self.store.value.id))
                })
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(Color.secondary)
                    .frame(width: 1, height: 20, alignment: .center)
                
                Text("Edit")
                    .foregroundColor(Color.white)
                    .padding()
                    .highPriorityGesture(TapGesture().onEnded {
                        self.store.send(.edit(self.store.value))
                    })
            }
            .background(Color.gray)
            .clipShape(Capsule())
            
        }.animation(.default)
        .padding()
    }
    
    var header: some View {
        VStack(alignment: .center) {
            ProfileImageHeader()//.transition(.opacity)
            (
                Text(store.value.firstName) +
                Text(" ") +
                Text(store.value.lastName)
            )
                .font(.largeTitle)
            Text(store.value.title)
        }
    }
    
    var fields: some View {
        ForEach(store.value.fields.groups.enumeratedArray(), id: \.offset) { fieldGroup in
            Section {
                ForEach(fieldGroup.element.fields.enumeratedArray(), id: \.offset) { field in
                    Text(field.element.value)
                }
            }
        }
    }
}



struct CardDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardDetailView(
                store: .init(initialValue: .luke, reducer: CardDetail.reducer)
            )
                .previewLayout(.sizeThatFits)
            
            CardDetailView(
                store: .init(initialValue: .luke, reducer: CardDetail.reducer)
            )
                .previewLayout(.sizeThatFits)
        }
        
    }
}

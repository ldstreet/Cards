//
//  CardDetail.swift
//  BusinessCard
//
//  Created by Luke Street on 10/29/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Models
import ComposableArchitecture

enum CardDetail {
    struct Environment {
        
    }
    
    typealias State = Card
}

struct CardDetailView: View {
    
    private let store: Store<CardDetail.State, CardDetail.Action>
    
    init(store: Store<CardDetail.State, CardDetail.Action>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                self.header
                self.fields
                HStack {
                    Text("Share")
                    .foregroundColor(Color.white)
                    .padding()
                    .highPriorityGesture(TapGesture().onEnded {
                        viewStore.send(.share(viewStore.state))
                    })
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(Color.secondary)
                        .frame(width: 1, height: 20, alignment: .center)
                    
                    Text("Edit")
                        .foregroundColor(Color.white)
                        .padding()
                        .highPriorityGesture(TapGesture().onEnded {
                            viewStore.send(.edit(viewStore.state))
                        })
                }
                .background(Color.gray)
                .clipShape(Capsule())
                
            }
            .animation(.default)
            .padding()
        }
    }
    
    var header: some View {
        VStack(alignment: .center) {
            ProfileImageHeader()
            WithViewStore(store) { viewStore in
                Text(viewStore.name)
                    .font(.largeTitle)
                Text(viewStore.title)
            }
        }
    }
    
    var fields: some View {
        WithViewStore(store) { viewStore in
            ForEach(0..<viewStore.groups.count) { groupIndex in
                ForEach(0..<viewStore.groups[groupIndex].fields.count) { fieldIndex in
                    Text(viewStore.groups[groupIndex].fields[fieldIndex].value)
                }
            }
        }
    }
}


//#if DEBUG
//struct CardDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            CardDetailView(
//                store: .init(initialValue: CardDetail.State(card: .luke), reducer: CardDetail.reducer, environment: .init())
//            )
//                .previewLayout(.sizeThatFits)
//
//            CardDetailView(
//                store: .init(initialValue: CardDetail.State(card: .luke), reducer: CardDetail.reducer, environment: .init())
//            )
//                .previewLayout(.sizeThatFits)
//        }
//
//    }
//}
//#endif

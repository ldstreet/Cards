//
//  CardView.swift
//  BusinessCard
//
//  Created by Luke Street on 9/2/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Models

struct CardPreviewView: View {
    let card: Card
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                (
                    Text(card.firstName) +
                    Text(" ") +
                    Text(card.lastName)
                ).tag(card.firstName + card.lastName)
                    .font(.headline)
                Text(card.title).font(.subheadline)
            }
            Spacer()
        }
        
    }
}

#if DEBUG
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardPreviewView(card: .luke)
            .previewLayout(.sizeThatFits)
    }
}
#endif

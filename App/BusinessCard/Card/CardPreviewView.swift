//
//  CardView.swift
//  BusinessCard
//
//  Created by Luke Street on 9/2/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI

struct CardPreviewView: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading) {
            (
                Text(card.firstName) +
                Text(" ") +
                Text(card.lastName)
            ).font(.headline)
            Text(card.title).font(.subheadline)
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

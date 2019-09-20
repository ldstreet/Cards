//
//  CardView.swift
//  BusinessCard
//
//  Created by Luke Street on 9/2/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    var body: some View {
        VStack {
            (Text(card.firstName) + Text(" ") + Text(card.lastName)).font(.largeTitle)
            Text(card.title).font(.title)
            ForEach(card.fields.groups.flatMap { $0.fields }) { field in
                Text(field.value)
                    .font(.headline)
            }
        }
    }
}

#if DEBUG
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .luke)
            .previewLayout(.sizeThatFits)
    }
}
#endif

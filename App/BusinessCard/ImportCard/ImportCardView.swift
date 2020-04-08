//
//  CardsView.swift
//  BusinessCard
//
//  Created by Luke Street on 10/26/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI

struct ImportCardView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Rectangle().foregroundColor(Color.red)
                
                Spacer()
            }
            Spacer()
            HStack {
                Button(action: {}, label: { Text("Capture") })
                    .padding()
                    .border(Color.black, width: 2)
                Button(action: {}, label: { Text("Dismiss") })
                    .padding()
                    .border(Color.black, width: 2)
            }
        }
    }
}


struct ImportCardView_Preview: PreviewProvider {
    static var previews: ImportCardView { ImportCardView() }
}

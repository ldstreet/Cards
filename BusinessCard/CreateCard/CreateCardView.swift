//
//  CreateCardView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

struct CreateCardState: Codable {
    
}

enum CreateCardAction {
    case something
}

let createCardReducer: Reducer<CreateCardState, CreateCardAction> = { state, action in
    
}

struct CreateCardView: View {
    
    var store: Store<CreateCardState, CreateCardAction>
    
    var body: some View {
        Text("Create Card")
    }
}

#if DEBUG
struct CreateCardView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCardView(store: .init(initialValue: .init(), reducer: createCardReducer))
    }
}
#endif

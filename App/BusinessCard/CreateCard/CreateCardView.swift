//
//  CreateCardView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux
import Models
import Combine

enum CreateCard {}

extension CreateCard {
    struct View: SwiftUI.View {
        
        @ObservedObject var store: Store<State, Action>
        
        var body: some SwiftUI.View {
            NavigationView {
                Form {
                    Section(header:
                        HStack {
                            Spacer()
                            ProfileImageHeader()
                            Spacer()
                        }
                    ) {
                        TextField(
                            "Jane",
                            text: store.send(
                                Action.firstNameChanged,
                                binding: \.card.firstName
                            )
                        ).textContentType(.givenName)
                        
                        TextField(
                            "Doe",
                            text: store.send(
                                Action.lastNameChanged,
                                binding: \.card.lastName
                            )
                        ).textContentType(.familyName)
                        
                        TextField(
                            "Project Manager",
                            text: store.send(
                                Action.titleChanged,
                                binding: \.card.title
                            )
                        ).textContentType(.jobTitle)
                    }
                    ForEach(0..<self.store.value.card.groups.count) { index in
                        FieldGroup.View(
                            store: self.store.view(
                                value: { $0.card.groups[index] },
                                action: { .groups(Indexed(index: index, value: $0)) }
                            )
                        )
                    }
                }
                .navigationBarTitle("Create Card")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        self.store.send(.cancel)
                    },
                    trailing: Button("Done") {
                        self.store.send(.done)
                    }
                )
            }
        }
    }
}



extension Sequence {
    func enumeratedArray() -> [(offset: Int, element: Element)] { return Array(enumerated()) }
}

#if DEBUG
struct CreateCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateCard.View(
                store: Store(
                    initialValue: .init(card: .createDefaultCard()),
                    reducer: CreateCard.reducer
                )
            )
            Text("Some View")
                .sheet(isPresented: Binding<Bool>(get: { return true }, set: {_ in})) {
                    CreateCard.View(store: .init(
                        initialValue: CreateCard.State(card: .createDefaultCard()),
                        reducer: CreateCard.reducer
                    ))
            }
        }
        
    }
}
#endif

struct ProfileImageHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .clipShape(Circle())
                .frame(width: 100.0, height: 100.0)
        }
    }
}

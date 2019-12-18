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
                    
                    ForEach(self.store.value.card.fields.groups.enumeratedArray(), id: \.offset) { fieldGroup in
                        Section {
                            ForEach(fieldGroup.element.fields.enumeratedArray(), id: \.offset) { field in
                                FieldCell(
                                    store: self.store,
                                    field: field,
                                    fieldGroup: fieldGroup
                                )
                            }
                        }
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

struct SpecifierPicker: View {
    
    let store: Store<CreateCard.State, CreateCard.Action>
    
    let indexPath: IndexPath
    let specifiers: [String]
    
    var body: some View {
        Picker(
            "",
            selection: self.store.send(
                CreateCard.Action.fieldSpecifierChanged,
                binding: { state, indexPath in
                    return state
                        .card
                        .fields
                        .groups[indexPath.section]
                        .fields[indexPath.item]
                        .specifierIndex
                },
                suppl: indexPath
            )
        ) {
            ForEach(
                Array(specifiers.enumerated()),
                id: \.offset
            ) { specifier in
                Text(specifier.element).tag(specifier.offset)
            }
        }.frame(minWidth: 45, idealWidth: 50, maxWidth: 75, alignment: .topLeading)
    }
}

struct FieldCell: View {
    
    let store: Store<CreateCard.State, CreateCard.Action>
    let field: (element: Card.Fields.Group.Field, offset: Int)
    let fieldGroup: (element: Card.Fields.Group, offset: Int)
    
    var body: some View {
        HStack {
            SpecifierPicker(
                store: self.store,
                indexPath: IndexPath(
                    item: field.offset,
                    section: fieldGroup.offset
                ),
                specifiers: field.element.type.specifiers
            )
            Divider()
            TextField(
                field.element.type.rawValue,
                text: self.store.send(
                    CreateCard.Action.fieldChanged,
                    binding: { state, indexPath in
                        return state
                            .card
                            .fields
                            .groups[indexPath.section]
                            .fields[indexPath.item]
                            .value
                    },
                    suppl: IndexPath(
                        item: field.offset,
                        section: fieldGroup.offset
                    )
                )
            )
                .keyboardType(field.element.type.keyboardType)
                .textContentType(field.element.type.contentType)
        }
    }
}

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

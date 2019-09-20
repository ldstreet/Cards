//
//  CreateCardView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import Redux

extension Card {
    static func createDefaultCard() -> Card {
        .init(
            fields: [
                .init(type: .phoneNumber, specifier: "cell", value: ""),
                .init(type: .phoneNumber, specifier: "work", value: ""),
                .init(type: .emailAddress, specifier: "work", value: ""),
                .init(type: .address, specifier: "work", value: "")
            ]
        )
    }
    
    var hasBeenChanged: Bool {
        return
            !firstName.isEmpty ||
            !lastName.isEmpty ||
            !title.isEmpty ||
            fields.hasBeenChanged
    }
}

extension Card.Fields {
    var hasBeenChanged: Bool {
        return groups.reduce(false, { return $0 || $1.hasBeenChanged })
    }
}

extension Card.Fields.Group {
    var hasBeenChanged: Bool {
        return fields.reduce(false, { return $0 || $1.hasBeenChanged })
    }
}

extension Card.Fields.Group.Field {
    var hasBeenChanged: Bool {
        return false
    }
}

extension Card.Fields.Group.Field {
    var specifierIndex: Int {
        get { type.specifiers.firstIndex(where: { $0 == self.specifier })! }
        set { specifier = type.specifiers[newValue] }
    }
}


struct CreateCardState: Codable, Identifiable {
    let id = UUID()
    var card = Card.createDefaultCard()
}

enum CreateCardAction {
    case firstNameChanged(String)
    case lastNameChanged(String)
    case titleChanged(String)
    case fieldChanged(value: String, indexPath: IndexPath)
    case fieldSpecifierChanged(specifierIndex: Int, indexPath: IndexPath)
    case cancel
    case done
}

let createCardReducer: Reducer<CreateCardState, CreateCardAction> = { state, action in
    switch action {
    case .firstNameChanged(let str):
        state.card.firstName = str
    case .lastNameChanged(let str):
        state.card.lastName = str
    case .titleChanged(let str):
        state.card.title = str
    case .fieldChanged(let value, let indexPath):
        state.card.fields.groups[indexPath.section].fields[indexPath.item].value = value
    case .fieldSpecifierChanged(let specifierIndex, let indexPath):
        state.card.fields.groups[indexPath.section].fields[indexPath.item].specifierIndex = specifierIndex
    case .cancel: break
    case .done: break
    }
}

struct CreateCardView: View {
    
    @ObservedObject var store: Store<CreateCardState, CreateCardAction>
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(
                        header:
                        ProfileImageHeader()
                    ) {
                        TextField(
                            "Jane",
                            text: store.send(
                                CreateCardAction.firstNameChanged,
                                binding: \.card.firstName
                            )
                        )
                        TextField(
                            "Doe",
                            text: store.send(
                                CreateCardAction.lastNameChanged,
                                binding: \.card.lastName
                            )
                        )
                        TextField(
                            "Project Manager",
                            text: store.send(
                                CreateCardAction.titleChanged,
                                binding: \.card.title
                            )
                        )
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

extension Sequence {
    func enumeratedArray() -> [(offset: Int, element: Element)] { return Array(enumerated()) }
}

#if DEBUG
struct CreateCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateCardView(
                store: Store(initialValue: .init(card: .createDefaultCard()), reducer: createCardReducer)
            )
            Text("Some View").sheet(isPresented: Binding<Bool>(get: { return true }, set: {_ in})) {
                CreateCardView(
                    store: Store(initialValue: .init(card: .createDefaultCard()), reducer: createCardReducer)
                )
            }
        }
        
    }
}
#endif

struct SpecifierPicker: View {
    let store: Store<CreateCardState, CreateCardAction>
    let indexPath: IndexPath
    let specifiers: [String]
    
    var body: some View {
        Picker(
            "",
            selection: self.store.send(
                CreateCardAction.fieldSpecifierChanged,
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
    
    let store: Store<CreateCardState, CreateCardAction>
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
                    CreateCardAction.fieldChanged,
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
        }
    }
}

struct ProfileImageHeader: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "person.fill")
                .resizable()
                .clipShape(Circle())
                .frame(width: 100.0, height: 100.0)
            Spacer()
        }
    }
}

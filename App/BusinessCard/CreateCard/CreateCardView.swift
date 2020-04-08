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
import VisionKit

enum CreateCard {
    struct Environment {
        
    }
}

extension CreateCard {
    struct View: SwiftUI.View {
        
        private let store: Store<State, Action>
        @ObservedObject var viewStore: ViewStore<State, Action>
        
        init(store: Store<State, Action>) {
            self.store = store
            self.viewStore = store.view
        }
        
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
                            "Jane Doe",
                            text: viewStore.send(
                                Action.nameChanged,
                                binding: \.card.name
                            )
                        ).textContentType(.name)

                        TextField(
                            "Project Manager",
                            text: viewStore.send(
                                Action.titleChanged,
                                binding: \.card.title
                            )
                        ).textContentType(.jobTitle)
                    }
                    ForEach(0..<self.viewStore.value.card.groups.count) { index in
                        FieldGroup.View(
                            store: self.store.scope(
                                value: { $0.card.groups[index] },
                                action: { .groups(Indexed(index: index, value: $0)) }
                            )
                        )
                    }
                    #if targetEnvironment(simulator)
                    
                    Button(
                        "Import via camera",
                        action: { self.viewStore.send(.scanResult([UIImage(named: "card1.png")!])) }
                    )
                    
                    #else
                    NavigationLink(
                        "Import via camera",
                        destination: DocumentCameraView { result in
                            switch result {
                            case .didFinishWith(let scan):
                                self.store.send(.scanResult(scan))
                            case .didCancel:
                                self.store.send(.showCameraImport(false))
                            case .didFailWith:
                                self.store.send(.showCameraImport(false))
                            }
                        },
                        isActive: self.store.send(
                            { .showCameraImport($0) },
                            binding: \.showCameraImport
                        )
                    )
                    #endif
                    
                }
                .navigationBarTitle("Create Card")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        self.viewStore.send(.cancel)
                    },
                    trailing: Button("Done") {
                        self.viewStore.send(.done)
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
//            CreateCard.View(
//                store: Store(
//                    initialValue: .init(card: .createDefaultCard()),
//                    reducer: CreateCard.reducer
//                )
//            )
            Text("Some View")
                .sheet(isPresented: Binding<Bool>(get: { return true }, set: {_ in})) {
                    CreateCard.View(store: Store(
                        initialValue: CreateCard.State(card: .createDefaultCard()),
                        reducer: CreateCard.reducer,
                        environment: CreateCard.Environment()
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

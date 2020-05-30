//
//  CreateCardView.swift
//  BusinessCard
//
//  Created by Luke Street on 8/31/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
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
        
        init(store: Store<State, Action>) {
            self.store = store
        }
        
        var body: some SwiftUI.View {
            WithViewStore(store) { viewStore in
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
                                text: viewStore.binding(
                                    get: \.card.name,
                                    send: Action.nameChanged
                                )
                            ).textContentType(.name)

                            TextField(
                                "Project Manager",
                                text: viewStore.binding(
                                    get: \.card.title,
                                    send: Action.titleChanged
                                )
                            ).textContentType(.jobTitle)
                        }
                        ForEachStore(
                            self.store.scope(
                                state: \.card.groups,
                                action: CreateCard.Action.groups
                            ),
                            content: FieldGroup.View.init
                        )
                        #if targetEnvironment(simulator)
                        Button(
                            "Import via camera (test)",
                            action: { viewStore.send(.scanResult([UIImage(named: "card1.png")!])) }
                        )
                        #else
                        NavigationLink(
                            "Import via camera",
                            destination: DocumentCameraView { result in
                                switch result {
                                case .didFinishWith(let scan):
                                    viewStore.send(.scanResult(scan.images))
                                case .didCancel:
                                    viewStore.send(.showCameraImport(false))
                                case .didFailWith:
                                    viewStore.send(.showCameraImport(false))
                                }
                            },
                            isActive: viewStore.binding(
                                get: \.showCameraImport,
                                send: Action.showCameraImport
                            )
                        )
                        #endif
                        
                    }
                    .navigationBarTitle("Create Card")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            viewStore.send(.cancel)
                        },
                        trailing: Button("Done") {
                            viewStore.send(.done)
                        }
                    )
                }
            }
        }
    }
}

extension VNDocumentCameraScan {
    var images: [UIImage] {
        (0..<self.pageCount).map(imageOfPage(at:))
    }
}

extension Sequence {
    func enumeratedArray() -> [(offset: Int, element: Element)] { return Array(enumerated()) }
}

#if DEBUG
struct CreateCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Text("hi")
//            CreateCard.View(
//                store: Store(
//                    initialValue: .init(card: .createDefaultCard()),
//                    reducer: CreateCard.reducer
//                )
//            )
//            Text("Some View")
//                .sheet(isPresented: Binding<Bool>(get: { return true }, set: {_ in})) {
//                    CreateCard.View(store: Store(
//                        initialValue: CreateCard.State(card: .createDefaultCard()),
//                        reducer: CreateCard.reducer,
//                        environment: CreateCard.Environment()
//                    ))
//            }
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

//
//  DocumentCameraView.swift
//  CardsShare
//
//  Created by Luke Street on 6/14/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import VisionKit
import Combine
import SwiftUI


struct DocumentCameraView: UIViewControllerRepresentable {
    
    public init(onCompletion: @escaping (DocumentResult) -> Void) {
        self.onCompletion = onCompletion
        self.subscriber = .init(receiveCompletion: { completion in
            return
        }, receiveValue: { result in
            onCompletion(result)
        })
        self.delegate.subject.subscribe(subscriber)
    }
    
    enum DocumentResult {
        case didFinishWith(_ scan: VNDocumentCameraScan)
        case didCancel
        case didFailWith(_ error: Error)
    }
    
    private final class Delegate: NSObject, VNDocumentCameraViewControllerDelegate {
        
        let subject = PassthroughSubject<DocumentResult, Never>()
        
        override init() {}
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            subject.send(.didFinishWith(scan))
        }
        
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            subject.send(.didFailWith(error))
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            
            subject.send(.didCancel)
        }
    }
    
    private let delegate = Delegate()
    
    private let onCompletion: (DocumentResult) -> Void
    private let subscriber: Subscribers.Sink<DocumentResult, Never>
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentCameraView>) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = delegate
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<DocumentCameraView>) { }
}

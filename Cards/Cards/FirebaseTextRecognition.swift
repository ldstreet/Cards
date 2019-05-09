//
//  FirebaseOCR.swift
//  Cards
//
//  Created by Luke Street on 3/12/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Foundation
import LDSiOSKit
import Firebase

public struct EmptyResult: Error {}

public func firebaseConvert(_ image: UIImage, completion: @escaping ResultClosure<String, Error>) {
    
    let vision = Vision.vision()
    let textRecognizer = vision.onDeviceTextRecognizer()
    let vImage = VisionImage(image: image)

    textRecognizer.process(vImage) { result, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let result = result else { completion(.failure(EmptyResult())); return }

        completion(.success(result.text))
    }
}

//
//  TextRecognition.swift
//  CardsShare
//
//  Created by Luke Street on 6/24/19.
//  Copyright © 2019 Luke Street. All rights reserved.
//

import Vision
import Combine
import UIKit

let textRecognition: (UIImage) -> Future<String, Error> = { image in
    
    return Future<String, Error> { promise in
        do {
            let recognizer = VNRecognizeTextRequest { (request, error) in
                var results = ""
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    print("The observations are of an unexpected type.")
                    return
                }
                // Concatenate the recognised text from all the observations.
                let maximumCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    results += candidate.string + "\n"
                }
                promise(.success(results))
            }
            recognizer.recognitionLevel = .accurate
            let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            try requestHandler.perform([recognizer])
        } catch {
            promise(.failure(error))
        }
    }
}

//
//  TextRecognitionTests.swift
//  BusinessCardTests
//
//  Created by Luke Street on 1/31/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import XCTest
@testable import BusinessCard

final class TextRecognitionTests: XCTestCase {
    
    func testRecognition() {
        
        let expect = expectation(description: "waiting for text recognition")
        
        guard let cancellable = Bundle(for: TextRecognitionTests.self)
            .path(forResource: "card1", ofType: "png")
            .flatMap(UIImage.init(contentsOfFile:))
            .flatMap(textRecognition)?
            .replaceError(with: "")
            .sink(receiveValue: { value in
                let expectedResult = """
                John Smith
                Civill Engineer
                123.456.7890
                123 somewhere,
                info@youremail.com
                City, State 12345
                www.yourwebsite.com

                """
                XCTAssertEqual(value, expectedResult)
                expect.fulfill()
            }) else {
                XCTFail("Couldn't create image")
                return
            }
        
        print(cancellable)
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
    
    }
}

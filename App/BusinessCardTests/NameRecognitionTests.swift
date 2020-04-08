//
//  NameRecognitionTesting.swift
//  BusinessCardTests
//
//  Created by Luke Street on 1/31/20.
//  Copyright © 2020 Luke Street. All rights reserved.
//

import XCTest
@testable import BusinessCard

final class NameRecognitionTests: XCTestCase {
    func testNames() {
        let sampleCardString = """
        John Smith
        Civil Engineer
        123.456.7890
        123 somewhere,
        info@youremail.com
        City, State 12345
        www.yourwebsite.com

        """
        let names = detectName(from: sampleCardString)
        XCTAssertEqual(names, ["John Smith"])
    }
}

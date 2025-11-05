//
//  TranscriptUiTests.swift
//  GameFrameIOSUITests
//
//  Created by Mélina Rochon on 2025-10-28.
//

import XCTest

final class TranscriptUiTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    /// Tests to add
    /// 1. View a specific transcript
    /// 2. View all transcripts
    /// Filter transcripts (when view all)
    /// 3. Edit a specific transcript
    ///     - Edit transcription
    ///     - Edit feedback for
    /// 4. Search for a transcript  (in the search bar)
    /// 5. Delete a transcript

}

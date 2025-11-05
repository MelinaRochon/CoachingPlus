//
//  GameFrameIOSUITests.swift
//  GameFrameIOSUITests
//
//  Created by Mélina Rochon on 2025-01-30.
//

import XCTest

final class GameFrameIOSUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        // Reset data to start fresh
        app.launchArguments = ["UI_TESTING_MODE", "RESET_DATA"]
        app.launch()

        let loginButton = app.buttons["loginButton"]
        let loginAsCoachButton = app.buttons["loginAsCoachButton"]
        
        // Tap login
        loginButton.tap()
        loginAsCoachButton.tap()
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

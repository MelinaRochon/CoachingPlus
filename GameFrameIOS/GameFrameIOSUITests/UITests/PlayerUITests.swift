//
//  PlayerUITests.swift
//  GameFrameIOSUITests
//
//  Created by Mélina Rochon on 2025-10-28.
//

import XCTest

final class PlayerUITests: XCTestCase {
    
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
    /// 1. Go to profile
    /// 2. Edit profile
    /// 3. Logout -> Maybe in authentication instead
    /// 4. Reset password (make that work)
    /// 5. Add team (with access code)
    ///     - invalid test: Add invalid access code
    /// 6. View team's roster
    /// 16. View full game transcript
    
}

//
//  LaunchPageUITests.swift
//  GameFrameIOSUITests
//
//  Created by Mélina Rochon on 2025-10-25.
//

import XCTest
import GameFrameIOSShared

final class LaunchPageUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Reset data to start fresh
        app.launchArguments = ["UI_TESTING_MODE", "RESET_DATA"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        app.terminate()
    }
    
    func testLaunchScreenAppearsOnLaunch() throws {
        XCTAssertTrue(app.staticTexts["gameframeWelcomeLabel"].exists)
        XCTAssertTrue(app.staticTexts["gameframeSloganLabel"].exists)
    }
    
    func testHowWeRollScreenAppearsOnTap() throws {
        let howWeRollLink = app.buttons["aboutPageNavLink"]
        XCTAssertTrue(howWeRollLink.exists, "Navigation link to About page should exist")
            
        // Tap it to navigate
        howWeRollLink.tap()
        
        // Verify that the destination screen is visible
        let aboutPageTitle = app.staticTexts["aboutPage.welcomeMessage"]
        XCTAssertTrue(aboutPageTitle.waitForExistence(timeout: 5), "About screen should appear")
    }
    
    func testPricingScreenAppearsOnTap() throws {
        let pricingLink = app.buttons["pricingNavLink"]
        XCTAssertTrue(pricingLink.exists, "Navigation link to Pricing page should exist")
            
        // Tap it to navigate
        pricingLink.tap()
        
        // Verify that the destination screen is visible
        let pricingPageTitle = app.staticTexts["pricingPage.title"]
        XCTAssertTrue(pricingPageTitle.waitForExistence(timeout: 5), "Pricing screen should appear")
        
        XCTAssertEqual(
            app.staticTexts["pricing.selectedPlan.label"].label,
            "Select a plan to see details"
        )
    }
    
    func testPricingPlanFree() throws {
        let pricingLink = app.buttons["pricingNavLink"]
        XCTAssertTrue(pricingLink.exists)
            
        // Tap it to navigate
        pricingLink.tap()
        
        // Verify that the destination screen is visible
        let pricingPageTitle = app.staticTexts["pricingPage.title"]
        XCTAssertTrue(pricingPageTitle.waitForExistence(timeout: 5), "Pricing screen should appear")
        
        // Tap to get the free pricing info
        app.buttons["pricing.plan.free.btn"].tap()
        
        // Make sure the description showed on the screen matches the free plan
        XCTAssertEqual(
            app.staticTexts["pricing.selectedPlan.label"].label,
            PricingPlan.free.description
        )
    }
    
    func testPricingPlanPlus() throws {
        let pricingLink = app.buttons["pricingNavLink"]
        XCTAssertTrue(pricingLink.exists)
            
        // Tap it to navigate
        pricingLink.tap()
        
        // Verify that the destination screen is visible
        let pricingPageTitle = app.staticTexts["pricingPage.title"]
        XCTAssertTrue(pricingPageTitle.waitForExistence(timeout: 5), "Pricing screen should appear")
        
        // Tap to get the free pricing info
        app.buttons["pricing.plan.plus.btn"].tap()
        
        // Make sure the description showed on the screen matches the plus plan
        XCTAssertEqual(
            app.staticTexts["pricing.selectedPlan.label"].label,
            PricingPlan.plus.description
        )
    }
    
    func testPricingPlanPremium() throws {
        let pricingLink = app.buttons["pricingNavLink"]
        XCTAssertTrue(pricingLink.exists)
            
        // Tap it to navigate
        pricingLink.tap()
        
        // Verify that the destination screen is visible
        let pricingPageTitle = app.staticTexts["pricingPage.title"]
        XCTAssertTrue(pricingPageTitle.waitForExistence(timeout: 5), "Pricing screen should appear")
        
        // Tap to get the free pricing info
        app.buttons["pricing.plan.premium.btn"].tap()
        
        // Make sure the description showed on the screen matches the premium plan
        XCTAssertEqual(
            app.staticTexts["pricing.selectedPlan.label"].label,
            PricingPlan.premium.description
        )
    }
}

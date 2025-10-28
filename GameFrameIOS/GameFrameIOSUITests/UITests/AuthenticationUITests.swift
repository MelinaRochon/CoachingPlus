//
//  AuthenticationUITests.swift
//  GameFrameIOSUITests
//
//  Created by Mélina Rochon on 2025-10-25.
//

import XCTest
@testable import GameFrameIOSShared

final class AuthenticationUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Reset data to start fresh
        app.launchArguments = ["DEBUG_NO_FIREBASE", "RESET_DATA", "UI_TEST_MODE"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        app.terminate()
    }
    
    // 1. Test login as coach
    func testLoginAsCoach() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["loginChoicePage.title"].exists)
        // Confirm that the argument is passed

        // Select login as a coach
        let login = app.buttons["loginChoicePage.login.coach.btn"]
        XCTAssertTrue(login.exists)
        login.tap()
        
        // Login as a coach
        XCTAssertTrue(app.staticTexts["coachLoginPage.title"].exists)
        let emailField = app.textFields["coachLoginPage.emailField"]
        emailField.tap()
        emailField.typeText("coach1@example.com")
        app.keyboards.buttons["Return"].tap() // Dismiss keyboard
        let pwdField = app.secureTextFields["coachLoginPage.passwordField"]
        XCTAssertTrue(pwdField.waitForExistence(timeout: 3))
        pwdField.tap()
        pwdField.typeText("alicesmith")
        
        // Login
        app.buttons["coachLoginPage.signInButton"].tap()
        let profilePage = app.otherElements["page.coach.profile"]
        XCTAssertTrue(profilePage.exists, "Profile page did not load")
    }
    
    // 2. Test login as player
    func testLoginAsPlayer() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["loginChoicePage.title"].exists)
        // Confirm that the argument is passed

        // Select login as a player
        let login = app.buttons["loginChoicePage.login.player.btn"]
        XCTAssertTrue(login.exists)
        login.tap()
        
        // Login as a player
        let playLoginPage = app.otherElements["page.player.login"]
        XCTAssertTrue(playLoginPage.exists, "Player login page did not load")
        let emailField = app.textFields["page.player.login.emailField"]
        emailField.tap()
        emailField.typeText("player1@example.com")
        let pwdField = app.secureTextFields["page.player.login.passwordField"]
        XCTAssertTrue(pwdField.waitForExistence(timeout: 3))
        pwdField.tap()
        pwdField.typeText("janedoe")
        
        // Login
        app.buttons["page.player.login.signInBtn"].tap()
        
        // Make sure we see the profile page as the login should have worked
        let profilePage = app.otherElements["page.player.profile"]
        XCTAssertTrue(profilePage.exists, "Profile page did not load")
    }

    // MARK: Negative Tests
    // Test invalid login as coach with invalid email
    func testLoginAsCoachWithInvalidEmail() throws {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["loginChoicePage.title"].exists)
        // Confirm that the argument is passed

        // Select login as a coach
        let login = app.buttons["loginChoicePage.login.coach.btn"]
        XCTAssertTrue(login.exists)
        login.tap()
        
        // Login as a coach
        XCTAssertTrue(app.staticTexts["coachLoginPage.title"].exists)
        let emailField = app.textFields["coachLoginPage.emailField"]
        emailField.tap()
        emailField.typeText("coach@coach.com") // Invalid email
        let pwdField = app.secureTextFields["coachLoginPage.passwordField"]
        XCTAssertTrue(pwdField.waitForExistence(timeout: 3))
        pwdField.tap()
        pwdField.typeText("alicesmith")
        
        // Login should fail
        app.buttons["coachLoginPage.signInButton"].tap()
        
        // Make sure the alert is showing
        let alert = app.alerts["Account Not Found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert to login failed did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the email & password fields are empty (see the placeholder)
        let emailText = emailField.value as? String ?? ""
        let pwdText = pwdField.value as? String ?? ""
        XCTAssertTrue(
            emailText == "Email" || emailText.isEmpty,
            "Expected email field to be empty, but found: \(emailText)"
        )
        XCTAssertTrue(
            pwdText == "Password" || pwdText.isEmpty,
            "Expected password field to be empty, but found: \(pwdText)"
        )
        XCTAssertTrue(app.staticTexts["coachLoginPage.title"].exists)
    }

    // Test invalid login as coach with invalid password
    func testLoginAsCoachWithInvalidPwd() throws {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["loginChoicePage.title"].exists)
        // Confirm that the argument is passed

        // Select login as a coach
        let login = app.buttons["loginChoicePage.login.coach.btn"]
        XCTAssertTrue(login.exists)
        login.tap()
        
        // Login as a coach
        XCTAssertTrue(app.staticTexts["coachLoginPage.title"].exists)
        let emailField = app.textFields["coachLoginPage.emailField"]
        emailField.tap()
        emailField.typeText("coach1@example.com")
        let pwdField = app.secureTextFields["coachLoginPage.passwordField"]
        XCTAssertTrue(pwdField.waitForExistence(timeout: 3))
        pwdField.tap()
        pwdField.typeText("123456") // Invalid password
        
        // Login should fail
        app.buttons["coachLoginPage.signInButton"].tap()
        
        // Make sure the alert is showing
        let alert = app.alerts["Invalid credentials. Please try again."]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert to login failed did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the email & password fields are empty (see the placeholder)
        let emailText = emailField.value as? String ?? ""
        let pwdText = pwdField.value as? String ?? ""
        XCTAssertTrue(
            emailText == "Email" || emailText.isEmpty,
            "Expected email field to be empty, but found: \(emailText)"
        )
        XCTAssertTrue(
            pwdText == "Password" || pwdText.isEmpty,
            "Expected password field to be empty, but found: \(pwdText)"
        )
        XCTAssertTrue(app.staticTexts["coachLoginPage.title"].exists)
    }
    
    // Test invalid login as player invalid email
    func testLoginAsPlayerWithInvalidEmail() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["loginChoicePage.title"].exists)
        // Confirm that the argument is passed

        // Select login as a player
        let login = app.buttons["loginChoicePage.login.player.btn"]
        XCTAssertTrue(login.exists)
        login.tap()
        
        // Login as a player
        let playLoginPage = app.otherElements["page.player.login"]
        XCTAssertTrue(playLoginPage.exists, "Player login page did not load")
        let emailField = app.textFields["page.player.login.emailField"]
        emailField.tap()
        emailField.typeText("player1@player123.com")
        let pwdField = app.secureTextFields["page.player.login.passwordField"]
        XCTAssertTrue(pwdField.waitForExistence(timeout: 3))
        pwdField.tap()
        pwdField.typeText("janedoe")
        
        // Login
        app.buttons["page.player.login.signInBtn"].tap()
                
        // Make sure the alert is showing
        let alert = app.alerts["Account Not Found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert to login failed did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the email & password fields are empty (see the placeholder)
        let emailText = emailField.value as? String ?? ""
        let pwdText = pwdField.value as? String ?? ""
        XCTAssertTrue(
            emailText == "Email" || emailText.isEmpty,
            "Expected email field to be empty, but found: \(emailText)"
        )
        XCTAssertTrue(
            pwdText == "Password" || pwdText.isEmpty,
            "Expected password field to be empty, but found: \(pwdText)"
        )
    }
    
    // Test invalid login as player invalid password
    func testLoginAsPlayerWithInvalidPwd() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["loginChoicePage.title"].exists)
        // Confirm that the argument is passed
        
        // Select login as a player
        let login = app.buttons["loginChoicePage.login.player.btn"]
        XCTAssertTrue(login.exists)
        login.tap()
        
        // Login as a player
        let playLoginPage = app.otherElements["page.player.login"]
        XCTAssertTrue(playLoginPage.exists, "Player login page did not load")
        let emailField = app.textFields["page.player.login.emailField"]
        emailField.tap()
        emailField.typeText("player@example.com")
        let pwdField = app.secureTextFields["page.player.login.passwordField"]
        XCTAssertTrue(pwdField.waitForExistence(timeout: 3))
        pwdField.tap()
        pwdField.typeText("123456")
        
        // Login
        app.buttons["page.player.login.signInBtn"].tap()
        
        // Make sure the alert is showing
        let alert = app.alerts["Account Not Found"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert to login failed did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the email & password fields are empty (see the placeholder)
        let emailText = emailField.value as? String ?? ""
        let pwdText = pwdField.value as? String ?? ""
        XCTAssertTrue(
            emailText == "Email" || emailText.isEmpty,
            "Expected email field to be empty, but found: \(emailText)"
        )
        XCTAssertTrue(
            emailText == "Email" || emailText.isEmpty,
            "Expected email field to be empty, but found: \(emailText)"
        )
        XCTAssertTrue(
            pwdText == "Password" || pwdText.isEmpty,
            "Expected password field to be empty, but found: \(pwdText)"
        )
    }

    // Test sign up as coach
    func testSignUpAsCoach() throws {
        let signUpButton = app.buttons["page.landing.signup.coach"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["page.signup.coach.title"].exists)

        // Sign up as a coach
        let firstNameField = app.textFields["page.signup.coach.firstName"]
        firstNameField.tap()
        firstNameField.typeText("Anna")
        
        let lastNameField = app.textFields["page.signup.coach.lastName"]
        lastNameField.tap()
        lastNameField.typeText("Brison")

        let phoneField = app.textFields["page.signup.coach.phone"]
        phoneField.tap()
        phoneField.typeText("9991234567")

        app.swipeUp()

        let emailField = app.textFields["page.signup.coach.email"]
        emailField.tap()
        emailField.typeText("anna@hotmail.com")
        
        let pwdField = app.textFields["page.signup.coach.password"]
        pwdField.tap()
        pwdField.typeText("annabrison")

        // Login
        app.buttons["page.signup.coach.createAccountBtn"].tap()
        sleep(3)
        let profilePage = app.otherElements["page.coach.profile"]
        XCTAssertTrue(profilePage.exists, "Profile page did not load")
    }
    
    // Test sign up as player
    func testSignUpAsPlayer() {
        let signUpButton = app.buttons["page.landing.signup.player"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["page.signup.player.title"].exists)

        // Sign up as a coach
        let teamAcessCodeField = app.textFields["page.signup.player.teamAccessCode"]
        teamAcessCodeField.tap()
        teamAcessCodeField.typeText("abc123")

        let emailField = app.textFields["page.signup.player.email"]
        emailField.tap()
        emailField.typeText("hailey@player.com")
        
        // Go to next step in sign up
        app.buttons["page.signup.player.continueBtn"].tap()
                
        let firstNameField = app.textFields["page.signup.player.firstName"]
        firstNameField.tap()
        firstNameField.typeText("Hailey")
        
        let lastNameField = app.textFields["page.signup.player.lastName"]
        lastNameField.tap()
        lastNameField.typeText("Dunphy")

        let phoneField = app.textFields["page.signup.player.phone"]
        phoneField.tap()
        phoneField.typeText("1234567890")
            
        let pwdField = app.textFields["page.signup.player.password"]
        pwdField.tap()
        pwdField.typeText("haileydunphy")
        
        // Confirm sign up and go to profile page
        app.buttons["page.signup.player.signUpBtn"].tap()
        sleep(3)
        let profilePage = app.otherElements["page.player.profile"]
        XCTAssertTrue(profilePage.exists, "Profile page did not load")
    }
    
    // Sign up player with invalid access code
    func testSignUpAsPlayerWithInvalidAccessCode() {
        let signUpButton = app.buttons["page.landing.signup.player"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["page.signup.player.title"].exists)

        // Sign up as a coach
        let teamAcessCodeField = app.textFields["page.signup.player.teamAccessCode"]
        teamAcessCodeField.tap()
        teamAcessCodeField.typeText("111111")

        let emailField = app.textFields["page.signup.player.email"]
        emailField.tap()
        emailField.typeText("hailey@player.com")
        
        // Go to next step in sign up
        app.buttons["page.signup.player.continueBtn"].tap()
        
        // Make sure the alert is showing
        let alert = app.alerts["Invalid Access Code"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert to invalid access code did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the team access code & password fields are empty (see the placeholder)
        let accessCodeTxt = teamAcessCodeField.value as? String ?? ""
        let emailTxt = emailField.value as? String ?? ""
        XCTAssertTrue(
            accessCodeTxt == "Team Access Code" || accessCodeTxt.isEmpty,
            "Expected team access code field to be empty, but found: \(accessCodeTxt)"
        )
        XCTAssertTrue(
            emailTxt == "Email" || emailTxt.isEmpty,
            "Expected email field to be empty, but found: \(emailTxt)"
        )
    }
    
    // Sign up player with email address that is already associated to a user in the database
    func testSignUpAsPlayerWithExistingEmail() {
        let signUpButton = app.buttons["page.landing.signup.player"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["page.signup.player.title"].exists)

        // Sign up as a coach
        let teamAcessCodeField = app.textFields["page.signup.player.teamAccessCode"]
        teamAcessCodeField.tap()
        teamAcessCodeField.typeText("abc123")

        let emailField = app.textFields["page.signup.player.email"]
        emailField.tap()
        emailField.typeText("player1@example.com") // email that already exists in database
        
        // Go to next step in sign up
        app.buttons["page.signup.player.continueBtn"].tap()
        
        // Make sure the alert is showing
        let alert = app.alerts["Account exists"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert account exist did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the team access code & password fields are empty (see the placeholder)
        let accessCodeTxt = teamAcessCodeField.value as? String ?? ""
        let emailTxt = emailField.value as? String ?? ""
        XCTAssertTrue(
            accessCodeTxt == "Team Access Code" || accessCodeTxt.isEmpty,
            "Expected team access code field to be empty, but found: \(accessCodeTxt)"
        )
        XCTAssertTrue(
            emailTxt == "Email" || emailTxt.isEmpty,
            "Expected email field to be empty, but found: \(emailTxt)"
        )
    }
    
    // Sign up coach with existing email address (user associated to the email used)
    func testSignUpAsCoachWithExistingEmail() throws {
        let signUpButton = app.buttons["page.landing.signup.coach"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        // Make sure the new page showed up
        XCTAssertTrue(app.staticTexts["page.signup.coach.title"].exists)

        // Sign up as a coach
        let firstNameField = app.textFields["page.signup.coach.firstName"]
        firstNameField.tap()
        firstNameField.typeText("Anna")
        
        let lastNameField = app.textFields["page.signup.coach.lastName"]
        lastNameField.tap()
        lastNameField.typeText("Brison")

        let phoneField = app.textFields["page.signup.coach.phone"]
        phoneField.tap()
        phoneField.typeText("9991234567")

        app.swipeUp()

        let emailField = app.textFields["page.signup.coach.email"]
        emailField.tap()
        emailField.typeText("coach1@example.com")
        
        let pwdField = app.textFields["page.signup.coach.password"]
        pwdField.tap()
        pwdField.typeText("annabrison")

        // Login should fail as email already exists
        app.buttons["page.signup.coach.createAccountBtn"].tap()
        
        // Make sure the alert is showing
        let alert = app.alerts["Account exists"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert account exist did not show up")
        alert.buttons["OK"].tap()
        
        // Make sure the team access code & password fields are empty (see the placeholder)
        let pwdTxt = pwdField.value as? String ?? ""
        let emailTxt = emailField.value as? String ?? ""
        XCTAssertTrue(
            pwdTxt == "Password" || pwdTxt.isEmpty,
            "Expected password field to be empty, but found: \(pwdTxt)"
        )
        XCTAssertTrue(
            emailTxt == "Email" || emailTxt.isEmpty,
            "Expected email field to be empty, but found: \(emailTxt)"
        )
    }
}

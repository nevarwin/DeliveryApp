//
//  DeliveryAppUITests.swift
//  DeliveryAppUITests
//
//  Created by raven on 11/18/25.
//

import XCTest

final class DeliveryAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Happy path smoke test
    @MainActor
    func testHappyPath_onboardingToCheckout() throws {
        let app = XCUIApplication()
        app.launch()
        
        // NOTE: These are intentionally high-level and resilient.
        // Adjust identifiers/labels as you refine the UI.
        
        // Onboarding
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        
        // Login
        if app.textFields["Email"].exists {
            app.textFields["Email"].tap()
            app.textFields["Email"].typeText("test@example.com")
        }
        
        if app.secureTextFields["Password"].exists {
            app.secureTextFields["Password"].tap()
            app.secureTextFields["Password"].typeText("password")
        }
        
        if app.buttons["Continue"].exists {
            app.buttons["Continue"].tap()
        }
        
        // Menu – assume at least one cell exists after load.
        // TODO: If you add explicit accessibility identifiers, use them here.
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
        }
        
        // Add to cart from detail
        if app.buttons["Add to Cart"].waitForExistence(timeout: 2) {
            app.buttons["Add to Cart"].tap()
        }
        
        // Open cart via cart button in navigation bar.
        // TODO: Give this button an accessibility identifier if needed.
        let cartButton = app.buttons["View cart"]
        if cartButton.waitForExistence(timeout: 2) {
            cartButton.tap()
        }
        
        // Proceed to checkout
        let checkoutCell = app.staticTexts["Proceed to Checkout"]
        if checkoutCell.waitForExistence(timeout: 2) {
            checkoutCell.tap()
        }
        
        // Fill minimal checkout fields (actual validation TBD).
        let fullNameField = app.textFields["Full name"]
        if fullNameField.waitForExistence(timeout: 2) {
            fullNameField.tap()
            fullNameField.typeText("Test User")
        }
        
        let addressField = app.textFields["Street address"]
        if addressField.exists {
            addressField.tap()
            addressField.typeText("123 Test Street")
        }
        
        let cityField = app.textFields["City"]
        if cityField.exists {
            cityField.tap()
            cityField.typeText("Testville")
        }
        
        let placeOrderButton = app.buttons["Place Order"]
        if placeOrderButton.waitForExistence(timeout: 2) {
            placeOrderButton.tap()
        }
        
        // TODO: Once `CheckoutController` sets `showConfirmation`, assert on the alert or next screen.
    }
}

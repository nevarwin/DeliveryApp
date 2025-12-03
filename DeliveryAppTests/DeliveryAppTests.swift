//
//  DeliveryAppTests.swift
//  DeliveryAppTests
//
//  Sample unit tests for cart, menu, and checkout logic.
//  Use these as a starting point and expand them as you build out features.
//

import Testing
@testable import DeliveryApp

struct DeliveryAppTests {
    
    // MARK: - Cart tests
    @Test func cartTotals_updateWhenItemsChange() async throws {
        let cart = CartController()
        let pizza = MenuItem(id: UUID(), name: "Pizza", description: "Test", price: 10, imageName: "takeoutbag.and.cup.and.straw.fill")
        let burger = MenuItem(id: UUID(), name: "Burger", description: "Test", price: 5, imageName: "takeoutbag.and.cup.and.straw.fill")
        
        // When: add items to the cart
        cart.addToCart(pizza)
        cart.addToCart(pizza)
        cart.addToCart(burger)
        
        // Then: totals should reflect quantity * price
        #expect(cart.totalItems == 3)
        #expect(cart.totalPrice == 25)
    }
    
    // MARK: - Menu tests
    @Test func menuStartsEmptyAndLoadsItems() async throws {
        let menu = MenuController()
        
        // Initially, the menu may be empty.
        #expect(menu.menuItems.isEmpty)
        
        // TODO: If you make `loadMenu()` async, await it here instead of direct call.
        menu.loadMenu()
        
        // TODO: Adjust this expectation once `loadMenu()` talks to real data.
        #expect(!menu.menuItems.isEmpty, "Expected `loadMenu()` to populate menuItems in this sample test.")
    }
    
    // MARK: - Checkout skeleton
    @Test func checkoutCanPlaceOrder_logicIsCustomizable() async throws {
        let checkout = CheckoutController()
        let cart = CartController()
        
        // TODO: Once you implement real validation, update this test
        // to cover both allowed and disallowed scenarios.
        //
        // Example structure:
        // - Empty name / address -> canPlaceOrder == false
        // - Valid name / address with non-empty cart -> canPlaceOrder == true
        
        #expect(checkout.canPlaceOrder, "Replace this with real assertions once `canPlaceOrder` is implemented.")
        
        // TODO: Later, call `await checkout.placeOrder(using: cart)` and
        // assert that it updates state / clears the cart as you expect.
    }
}



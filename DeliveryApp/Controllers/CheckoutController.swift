//
//  CheckoutController.swift
//  DeliveryApp
//
//  Controller for the checkout & payment flow in an MVC-style setup.
//  Fill in the TODOs for validation, payment, and order creation.
//

import Foundation
import Combine
internal import SwiftUI

/// High‑level payment options for the demo checkout flow.
enum PaymentMethod: CaseIterable {
    case applePay
    case card
    
    var displayName: String {
        switch self {
        case .applePay:
            return "Apple Pay"
        case .card:
            return "Card"
        }
    }
}

/// ObservableObject “controller” that owns all state for the checkout screen.
///
/// Responsibilities (you implement):
/// - Validate delivery details
/// - Trigger your real or mocked payment flow
/// - Create and persist an order
/// - Clear the cart / notify the rest of the app when done
final class CheckoutController: ObservableObject {
    // MARK: - Delivery details
    @Published var name: String = ""
    @Published var addressLine1: String = ""
    @Published var addressLine2: String = ""
    @Published var city: String = ""
    @Published var instructions: String = ""
    
    // MARK: - Payment
    @Published var selectedPaymentMethod: PaymentMethod = .applePay
    @Published var isProcessingPayment: Bool = false
    @Published var showConfirmation: Bool = false
    
    // MARK: - Derived state
    /// Decide when the "Place Order" button should be enabled.
    /// TODO: Replace this placeholder logic with your own validation rules.
    var canPlaceOrder: Bool {
        // Example implementation (replace or extend as you like):
        // - Require non‑empty cart
        // - Require non‑empty name / address / city
        true
    }
    
    // MARK: - Actions
    
    /// Main entry point from the view when the user taps "Place Order".
    ///
    /// You can:
    /// - Call into a payment SDK (Apple Pay, Stripe, etc.)
    /// - Create an Order model
    /// - Persist it to your database layer
    /// - Clear the cart when everything succeeds
    ///
    /// For now it's an async skeleton for you to implement.
    func placeOrder(using cart: CartController) async {
        // TODO: Implement your payment + order creation flow here.
        //
        // Suggested steps:
        // 1. Guard against multiple taps using `isProcessingPayment`.
        // 2. Validate `canPlaceOrder` and the contents of `cart.items`.
        // 3. Perform your asynchronous payment / network work.
        // 4. On success:
        //      - clear the cart (e.g. `cart.clearCart()`)
        //      - toggle `showConfirmation` so the view can show an alert or navigate.
        // 5. Handle and surface any errors you care about.
    }
}



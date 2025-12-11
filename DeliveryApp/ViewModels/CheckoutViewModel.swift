//
//  CheckoutViewModel.swift
//  DeliveryApp
//
//  Encapsulates checkout business rules for the checkout view.
//

import SwiftUI
internal import Combine

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

@MainActor
final class CheckoutViewModel: ObservableObject {
    // MARK: - Delivery details
    @Published var name: String = ""
    @Published var addressLine1: String = ""
    @Published var addressLine2: String = ""
    @Published var city: String = ""
    @Published var instructions: String = ""
    
    // MARK: - Payment
    @Published var selectedPaymentMethod: PaymentMethod = .applePay
    @Published private(set) var isProcessingPayment: Bool = false
    @Published var showConfirmation: Bool = false
    
    // MARK: - Derived state
    var canPlaceOrder: Bool {
        !isProcessingPayment &&
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !addressLine1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Actions
    func placeOrder(using cart: CartViewModel) async {
        guard !isProcessingPayment else { return }
        guard canPlaceOrder, !cart.items.isEmpty else { return }
        
        isProcessingPayment = true
        defer { isProcessingPayment = false }
        
        do {
            // Simulate network/payment delay
            try await Task.sleep(nanoseconds: 600_000_000)
            
            // TODO: integrate a real payment + order persistence layer.
            cart.clearCart()
            showConfirmation = true
        } catch {
            // Surface any cancellation errors here if needed.
        }
    }
}

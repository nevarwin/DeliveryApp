//
//  CheckoutView.swift
//  DeliveryApp
//
//  Skeleton SwiftUI checkout screen that uses `CheckoutViewModel`.
//  All business logic lives in the view model; this file is UI‑only.
//

internal import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cartController: CartController
    @Environment(\.dismiss) private var dismiss
    
    // MVC-style: the view owns its controller for this flow.
    @StateObject private var controller = CheckoutController()
    
    var body: some View {
        Form {
            // MARK: Delivery details
            Section("Delivery details") {
                TextField("Full name", text: $controller.name)
                TextField("Street address", text: $controller.addressLine1)
                TextField("Apartment, suite, etc. (optional)", text: $controller.addressLine2)
                TextField("City", text: $controller.city)
                
                TextField("Delivery instructions (optional)", text: $controller.instructions, axis: .vertical)
                    .lineLimit(2...4)
            }
            
            // MARK: Payment method
            Section("Payment") {
                Picker("Method", selection: $controller.selectedPaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.displayName).tag(method)
                    }
                }
                .pickerStyle(.segmented)
                
                // Skeleton explanatory text – replace with your real integration notes.
                switch controller.selectedPaymentMethod {
                case .applePay:
                    Text("TODO: Present Apple Pay sheet here.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                case .card:
                    Text("TODO: Integrate your card payment SDK (e.g. Stripe, Braintree).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: Order summary
            Section("Order summary") {
                ForEach(cartController.items) { cartItem in
                    HStack {
                        Text("\(cartItem.quantity)x \(cartItem.item.name)")
                        Spacer()
                        Text(Double(cartItem.quantity) * cartItem.item.price, format: .currency(code: "USD"))
                    }
                }
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(cartController.totalPrice, format: .currency(code: "USD"))
                        .font(.headline)
                }
            }
            
            // MARK: Map / delivery location (skeleton)
            Section("Delivery location") {
                NavigationLink {
                    DeliveryMapView()
                } label: {
                    HStack {
                        Image(systemName: "map")
                        Text("Set delivery location")
                        Spacer()
                    }
                }
                
                Text("TODO: Pass the selected map location back into `CheckoutViewModel`.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            // MARK: Place order button
            Section {
                Button {
                    Task {
                        await controller.placeOrder(using: cartController)
                        // TODO: You decide how / when to dismiss or navigate after success.
                        if controller.showConfirmation {
                            dismiss()
                        }
                    }
                } label: {
                    if controller.isProcessingPayment {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("Place Order")
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
                .disabled(!controller.canPlaceOrder || controller.isProcessingPayment)
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Order confirmed!", isPresented: $controller.showConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("TODO: Customize this confirmation message or navigate to a dedicated confirmation screen.")
        }
    }
}



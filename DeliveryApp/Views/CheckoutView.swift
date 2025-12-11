//
//  CheckoutView.swift
//  DeliveryApp
//
//  SwiftUI checkout screen that reads from CheckoutViewModel.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = CheckoutViewModel()
    
    var body: some View {
        Form {
            // MARK: Delivery details
            Section("Delivery details") {
                TextField("Full name", text: $viewModel.name)
                TextField("Street address", text: $viewModel.addressLine1)
                TextField("Apartment, suite, etc. (optional)", text: $viewModel.addressLine2)
                TextField("City", text: $viewModel.city)
                
                TextField("Delivery instructions (optional)", text: $viewModel.instructions, axis: .vertical)
                    .lineLimit(2...4)
            }
            
            // MARK: Payment method
            Section("Payment") {
                Picker("Method", selection: $viewModel.selectedPaymentMethod) {
                    ForEach(PaymentMethod.allCases, id: \.self) { method in
                        Text(method.displayName).tag(method)
                    }
                }
                .pickerStyle(.segmented)
                
                switch viewModel.selectedPaymentMethod {
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
                ForEach(cartViewModel.items) { cartItem in
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
                    Text(cartViewModel.totalPrice, format: .currency(code: "USD"))
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
                        await viewModel.placeOrder(using: cartViewModel)
                        if viewModel.showConfirmation {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isProcessingPayment {
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
                .disabled(!viewModel.canPlaceOrder || viewModel.isProcessingPayment)
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Order confirmed!", isPresented: $viewModel.showConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("TODO: Customize this confirmation message or navigate to a dedicated confirmation screen.")
        }
    }
}


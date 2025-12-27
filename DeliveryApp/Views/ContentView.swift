//
//  ContentView.swift
//  DeliveryApp
//
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var menuViewModel: MenuViewModel
    @EnvironmentObject private var cartViewModel: CartViewModel
    @EnvironmentObject private var authViewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if menuViewModel.menuItems.isEmpty {
                    ScrollView {
                        ContentUnavailableView("No dishes yet",
                                               systemImage: "takeoutbag.and.cup.and.straw.fill",
                                               description: Text("Pull to refresh to load the house specials."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                } else {
                    List {
                        ForEach(menuViewModel.menuItems) { item in
                            NavigationLink {
                                MenuDetailView(item: item)
                            } label: {
                                MenuRow(item: item)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            menuViewModel.deleteMenuItems(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .listStyle(.plain)
            .refreshable {
                menuViewModel.refreshData()
            }
            .onAppear {
                menuViewModel.refreshData()
            }
            .navigationTitle("Local Eats")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        CartView()
                            .environmentObject(cartViewModel)
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                            
                            if cartViewModel.totalItems > 0 {
                                Text("\(cartViewModel.totalItems)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Circle().fill(.red))
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .accessibilityLabel("View cart")
                }
            }
        }
    }
}

private struct MenuRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: item.imageName)
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(item.price, format: .currency(code: "USD"))
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

private struct MenuDetailView: View {
    let item: MenuItem
    @EnvironmentObject private var cartViewModel: CartViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.name)
                        .font(.largeTitle.bold())
                    Text(item.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text(item.price, format: .currency(code: "USD"))
                        .font(.title2.bold())
                    
                    Button {
                        cartViewModel.addToCart(item)
                    } label: {
                        Text("Add to Cart")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .padding(.top, 16)
                }
            }
            .padding()
        }
        .navigationTitle("Dish details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CartView: View {
    @EnvironmentObject private var cartViewModel: CartViewModel
    
    var body: some View {
        Group {
            if cartViewModel.items.isEmpty {
                ContentUnavailableView("Cart is empty",
                                       systemImage: "cart",
                                       description: Text("Add some tasty dishes to your cart to get started."))
            } else {
                List {
                    ForEach(cartViewModel.items) { cartItem in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cartItem.item.name)
                                    .font(.headline)
                                Text(cartItem.item.price, format: .currency(code: "USD"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(Double(cartItem.quantity) * cartItem.item.price, format: .currency(code: "USD"))
                                    .font(.headline)
                                
                                Stepper(
                                    "Qty: \(cartItem.quantity)",
                                    value: .init(
                                        get: { cartItem.quantity },
                                        set: { newValue in
                                            cartViewModel.updateQuantity(for: cartItem.item, quantity: newValue)
                                        }
                                    ),
                                    in: 1...20
                                )
                                .labelsHidden()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        cartViewModel.removeItems(at: offsets)
                    }
                    
                    Section {
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(cartViewModel.totalPrice, format: .currency(code: "USD"))
                                .font(.headline)
                        }
                    }
                    
                    Section {
                        NavigationLink {
                            CheckoutView()
                                .environmentObject(cartViewModel)
                        } label: {
                            HStack {
                                Spacer()
                                Text("Proceed to Checkout")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Your Cart")
        .toolbar {
            if !cartViewModel.items.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        cartViewModel.clearCart()
                    }
                }
            }
        }
    }
    #Preview {
        ContentView()
            .environmentObject(MenuViewModel())
            .environmentObject(CartViewModel())
    }
}

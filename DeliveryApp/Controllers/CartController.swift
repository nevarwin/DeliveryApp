//
//  CartController.swift
//  DeliveryApp
//
//  ObservableObject that manages items added to the cart.
//

import Foundation
import Combine

final class CartController: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.item.price) }
    }
    
    func addToCart(_ menuItem: MenuItem) {
        if let index = items.firstIndex(where: { $0.item.id == menuItem.id }) {
            items[index].quantity += 1
        } else {
            let cartItem = CartItem(item: menuItem, quantity: 1)
            items.append(cartItem)
        }
    }
    
    func updateQuantity(for menuItem: MenuItem, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.item.id == menuItem.id }) else { return }
        
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func clearCart() {
        items.removeAll()
    }
}



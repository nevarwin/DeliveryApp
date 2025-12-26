//
//  Models.swift
//  DeliveryApp
//
//  Basic data models for the food delivery app (MVC - Model layer).
//

import Foundation

struct MenuItem: Identifiable, Equatable {
    let id: Int64
    let firebaseID: String
    var name: String
    var description: String
    var price: Double
    var imageName: String
}

struct CartItem: Identifiable {
    let id = UUID()
    var item: MenuItem
    var quantity: Int
}



//
//  Models.swift
//  DeliveryApp
//
//  Basic data models for the flower delivery app (MVC - Model layer).
//

import Foundation

struct Flower: Identifiable, Equatable {
    let id: Int64
    var name: String
    var description: String
    var price: Double
    var imageName: String
}



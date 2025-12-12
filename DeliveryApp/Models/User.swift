//
//  User.swift
//  DeliveryApp
//
//  Created by raven on 12/12/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let avatarURL: String?
    let authProvider: AuthProvider
    
    enum AuthProvider: String, Codable {
        case email
        case google
        case apple
    }
}

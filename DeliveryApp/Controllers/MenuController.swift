//
//  MenuController.swift
//  DeliveryApp
//
//  ObservableObject controller that brokers MenuItem data to the UI.
//

import Foundation
import Combine

final class MenuController: ObservableObject {
    @Published private(set) var menuItems: [MenuItem] = []
    
    private let database = DatabaseManager.shared
    
    init() {
        loadMenu()
    }
    
    func loadMenu() {
        menuItems = database.fetchMenuItems()
    }
}

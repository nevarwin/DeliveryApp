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
    
    // MARK: - CRUD API
    
    func createMenuItem(name: String,
                        description: String,
                        price: Double,
                        imageName: String) {
        _ = database.insertMenuItem(name: name,
                                    description: description,
                                    price: price,
                                    imageName: imageName)
        loadMenu()
    }
    
    func updateMenuItem(_ item: MenuItem) {
        _ = database.updateMenuItem(item)
        loadMenu()
    }
    
    func deleteMenuItems(at offsets: IndexSet) {
        let idsToDelete = offsets.compactMap { index in
            menuItems[safe: index]?.id
        }
        
        for id in idsToDelete {
            _ = database.deleteMenuItem(id: id)
        }
        
        loadMenu()
    }
}

// MARK: - Safe index helper

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

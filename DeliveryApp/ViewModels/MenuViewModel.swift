//
//  MenuViewModel.swift
//  DeliveryApp
//
//  MVVM view model that feeds menu data to the UI.
//

import SwiftUI
internal import Combine

@MainActor
final class MenuViewModel: ObservableObject {
    
    @Published private(set) var menuItems: [MenuItem] = []
    
    // We use the Singleton directly for consistency
    private let db = DatabaseManager.shared
    
    init() {
        // Load local data immediately on startup
        loadLocalData()
    }
    
    // MARK: - Loading
    
    func loadLocalData() {
        self.menuItems = db.fetchMenuItems()
    }
    
    func refreshData() {
        // 1. Background Sync
        db.syncMenuWithFirebase { [weak self] success in
            if success {
                // 2. Refresh UI with new data
                DispatchQueue.main.async {
                    self?.loadLocalData()
                }
            }
        }
    }
    
    // MARK: - CRUD
    
    func createMenuItem(name: String, description: String, price: Double, imageName: String) {
        // Use the new Manager method that handles BOTH Local + Cloud
        db.createMenuItem(name: name, description: description, price: price, imageName: imageName)
        
        // Reload local array to update UI
        loadLocalData()
    }
    
    func updateMenuItem(_ item: MenuItem) {
        // You should add a similar 'update' method to DatabaseManager that handles Firestore
        db.updateMenuItemComposite(item)
        loadLocalData()
    }
    
    func deleteMenuItems(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let item = menuItems[safe: index] else { return }
            
            // The Manager now handles both SQLite and Firestore deletion
            db.deleteMenuItem(localID: item.id, firebaseID: item.firebaseID)
        }
        
        // Update UI immediately (Optimistic update)
        menuItems.remove(atOffsets: offsets)
    }
}

// MARK: - Safe index helper

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


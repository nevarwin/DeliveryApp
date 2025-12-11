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
    
    private let repository: MenuRepository
    
    init(repository: MenuRepository) {
        self.repository = repository
        // Defer initial load until after initialization completes
        Task { [weak self] in
            await self?.loadMenu()
        }
    }
    
    @MainActor
    convenience init() {
        self.init(repository: SQLiteMenuRepository())
    }
    
    func loadMenu() async {
        menuItems = repository.fetchMenuItems()
    }
    
    func createMenuItem(name: String,
                        description: String,
                        price: Double,
                        imageName: String) {
        repository.createMenuItem(name: name,
                                  description: description,
                                  price: price,
                                  imageName: imageName)
        Task { [weak self] in
            await self?.loadMenu()
        }
    }
    
    func updateMenuItem(_ item: MenuItem) {
        repository.updateMenuItem(item)
        Task { [weak self] in
            await self?.loadMenu()
        }
    }
    
    func deleteMenuItems(at offsets: IndexSet) {
        let idsToDelete = offsets.compactMap { index in
            menuItems[safe: index]?.id
        }
        repository.deleteMenuItems(ids: idsToDelete)
        Task { [weak self] in
            await self?.loadMenu()
        }
    }
}

// MARK: - Safe index helper

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


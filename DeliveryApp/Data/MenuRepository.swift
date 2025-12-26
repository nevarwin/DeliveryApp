////
////  MenuRepository.swift
////  DeliveryApp
////
////  Simple data abstraction between persistence and view models.
////
//
//import Foundation
//
//protocol MenuRepository {
//    func fetchMenuItems() -> [MenuItem]
//    func createMenuItem(name: String, description: String, price: Double, imageName: String)
//    func updateMenuItem(_ item: MenuItem)
//    func deleteMenuItems(ids: [Int64])
//}
//
//struct SQLiteMenuRepository: MenuRepository {
//    private let database: DatabaseManager
//    
//    init(database: DatabaseManager = .shared) {
//        self.database = database
//    }
//    
//    func fetchMenuItems() -> [MenuItem] {
//        database.fetchMenuItems()
//    }
//    
//    func createMenuItem(name: String, description: String, price: Double, imageName: String) {
//        _ = database.insertMenuItem(name: name,
//                                    description: description,
//                                    price: price,
//                                    imageName: imageName)
//    }
//    
//    func updateMenuItem(_ item: MenuItem) {
//        _ = database.updateMenuItem(item)
//    }
//    
//    func deleteMenuItems(ids: [Int64]) {
//        ids.forEach { id in
//            _ = database.deleteMenuItem(id: id)
//        }
//    }
//}

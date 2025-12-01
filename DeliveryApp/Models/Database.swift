//
//  Database.swift
//  DeliveryApp
//
//  Lightweight SQLite helper and repository for menu items.
//

import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let dbFileName = "DeliveryApp.sqlite"
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTablesIfNeeded()
        seedInitialMenuIfNeeded()
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    // MARK: - Setup
    
    private func openDatabase() {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsURL = urls.first else { return }
        let dbURL = documentsURL.appendingPathComponent(dbFileName)
        
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Unable to open database.")
            db = nil
        }
    }
    
    private func createTablesIfNeeded() {
        let createMenuTableSQL = """
        CREATE TABLE IF NOT EXISTS menu_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            imageName TEXT
        );
        """
        
        guard let db = db else { return }
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createMenuTableSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Could not create menu_items table.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Seeding
    
    private func seedInitialMenuIfNeeded() {
        if !fetchMenuItems().isEmpty {
            return
        }
        
        let initialMenu: [(String, String, Double, String)] = [
            ("Margherita Pizza", "Wood-fired pie with basil and mozzarella.", 14.99, "takeoutbag.and.cup.and.straw.fill"),
            ("Sushi Bento", "Chef's choice nigiri with sides.", 22.49, "fish.fill"),
            ("Vegan Buddha Bowl", "Roasted veggies, quinoa, tahini drizzle.", 17.99, "leaf.circle.fill"),
            ("BBQ Brisket Sandwich", "Slow-smoked brisket on brioche.", 15.49, "fork.knife.circle")
        ]
        
        for item in initialMenu {
            _ = insertMenuItem(name: item.0,
                               description: item.1,
                               price: item.2,
                               imageName: item.3)
        }
    }
    
    // MARK: - CRUD
    
    func fetchMenuItems() -> [MenuItem] {
        guard let db = db else { return [] }
        
        let querySQL = "SELECT id, name, description, price, imageName FROM menu_items ORDER BY name ASC;"
        var statement: OpaquePointer?
        var result: [MenuItem] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                
                var description = ""
                if let cString = sqlite3_column_text(statement, 2) {
                    description = String(cString: cString)
                }
                
                let price = sqlite3_column_double(statement, 3)
                
                var imageName = ""
                if let cString = sqlite3_column_text(statement, 4) {
                    imageName = String(cString: cString)
                }
                
                let item = MenuItem(id: id,
                                    name: name,
                                    description: description,
                                    price: price,
                                    imageName: imageName)
                result.append(item)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    @discardableResult
    func insertMenuItem(name: String, description: String, price: Double, imageName: String) -> Int64? {
        guard let db = db else { return nil }
        
        let insertSQL = "INSERT INTO menu_items (name, description, price, imageName) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (description as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 3, price)
            sqlite3_bind_text(statement, 4, (imageName as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Could not insert row.")
                sqlite3_finalize(statement)
                return nil
            }
        } else {
            print("INSERT statement could not be prepared.")
            sqlite3_finalize(statement)
            return nil
        }
        
        let lastId = sqlite3_last_insert_rowid(db)
        sqlite3_finalize(statement)
        return lastId
    }

    func updateMenuItem(_ item: MenuItem) -> Bool {
        guard let db = db else { return false }
        
        let updateSQL = "UPDATE menu_items SET name = ?, description = ?, price = ?, imageName = ? WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (item.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (item.description as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 3, item.price)
            sqlite3_bind_text(statement, 4, (item.imageName as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(statement, 5, item.id)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Could not update row.")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("UPDATE statement could not be prepared.")
            sqlite3_finalize(statement)
            return false
        }
        
        sqlite3_finalize(statement)
        return true
    }
    
    func deleteMenuItem(id: Int64) -> Bool {
        guard let db = db else { return false }
        
        let deleteSQL = "DELETE FROM menu_items WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, id)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Could not delete row.")
                sqlite3_finalize(statement)
                return false
            }
        } else {
            print("DELETE statement could not be prepared.")
            sqlite3_finalize(statement)
            return false
        }
        
        sqlite3_finalize(statement)
        return true
    }
}

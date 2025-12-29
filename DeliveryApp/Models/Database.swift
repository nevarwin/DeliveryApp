//
//  Database.swift
//  DeliveryApp
//
//  Lightweight SQLite helper and repository for menu items.
//

import Foundation
import SQLite3
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let dbFileName = "DeliveryApp.sqlite"
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTablesIfNeeded()
        migrateDatabase()
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
            firebase_id TEXT,
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
    
    // MARK: - Migration
    
    private func migrateDatabase() {
        guard let db = db else { return }
        
        // 1. Check if the column already exists to avoid errors
        let checkSQL = "PRAGMA table_info(menu_items);"
        var statement: OpaquePointer?
        var columnExists = false
        
        if sqlite3_prepare_v2(db, checkSQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let name = sqlite3_column_text(statement, 1) {
                    let columnName = String(cString: name)
                    if columnName == "firebase_id" {
                        columnExists = true
                        break
                    }
                }
            }
        }
        sqlite3_finalize(statement)
        
        // 2. If it doesn't exist, run the ALTER TABLE command
        if !columnExists {
            let alterSQL = "ALTER TABLE menu_items ADD COLUMN firebase_id TEXT;"
            if sqlite3_exec(db, alterSQL, nil, nil, nil) == SQLITE_OK {
                print("Successfully migrated: Added firebase_id column.")
            } else {
                print("Migration failed: Could not add firebase_id column.")
            }
        }
    }
    
    // MARK: - Seeding
    
    private func seedInitialMenuIfNeeded() {
        if !fetchMenuItems().isEmpty {
            return
        }
        
        let initialMenu: [(String, String, String, Double, String)] = [
            ("seed_pizza_01", "Margherita Pizza", "Wood-fired pie with basil and mozzarella.", 14.99, "takeoutbag.and.cup.and.straw.fill"),
            ("seed_sushi_01", "Sushi Bento", "Chef's choice nigiri with sides.", 22.49, "fish.fill"),
            ("seed_vegan_01", "Vegan Buddha Bowl", "Roasted veggies, quinoa, tahini drizzle.", 17.99, "leaf.circle.fill"),
            ("seed_brisket_01", "BBQ Brisket Sandwich", "Slow-smoked brisket on brioche.", 15.49, "fork.knife.circle")
        ]
        
        for item in initialMenu {
            _ = insertMenuItem(firebaseID: item.0,
                               name: item.1,
                               description: item.2,
                               price: item.3,
                               imageName: item.4)
        }
    }
    
    // MARK: - CRUD
    
    func fetchMenuItems() -> [MenuItem] {
        guard let db = db else { return [] }
        
        let querySQL = "SELECT id, name, description, price, imageName, firebase_id FROM menu_items ORDER BY name ASC;"
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
                
                var firebaseID = ""
                if let cString = sqlite3_column_text(statement, 5) {
                    firebaseID = String(cString: cString)
                }
                
                let item = MenuItem(id: id,
                                    firebaseID: firebaseID,
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
    func insertMenuItem(firebaseID: String, name: String, description: String, price: Double, imageName: String) -> Int64? {
        guard let db = db else { return nil }
        
        let insertSQL = "INSERT INTO menu_items (firebase_id, name, description, price, imageName) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (firebaseID as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (description as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 4, price)
            sqlite3_bind_text(statement, 5, (imageName as NSString).utf8String, -1, nil)
            
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

extension DatabaseManager {
    
    // 1. New method to sync local DB with Cloud DB
    func syncMenuWithFirebase(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let localItems = self.fetchMenuItems()
        
        db.collection("menu_items").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(true) // No data is effectively a success
                return
            }
            
            if documents.isEmpty && !localItems.isEmpty {
                print("Firebase empty, preserving local seeded data")
                completion(true)
                return
            }
            
            // 2. Clear current cache to ensure deleted items are removed
            self.clearMenuTable()
            
            // 3. Save new data from Firebase to SQLite
            for document in documents {
                let data = document.data()
                let docID = document.documentID
                
                let name = data["name"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let price = data["price"] as? Double ?? 0.0
                let imageName = data["imageName"] as? String ?? ""
                
                // Insert into local SQLite
                _ = self.insertMenuItem(firebaseID: docID,
                                        name: name,
                                        description: description,
                                        price: price,
                                        imageName: imageName)
            }
            
            // 4. Notify Caller
            completion(true)
        }
    }
    
    // Helper to clear table before re-populating
    private func clearMenuTable() {
        guard let db = db else { return }
        let deleteSQL = "DELETE FROM menu_items;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
}

// MARK: - Composite Actions (SQLite + Firebase)
// These methods bridge the gap between Local and Cloud.

extension DatabaseManager {
    
    /// Create a new item in BOTH Firebase and SQLite
    func createMenuItem(name: String, description: String, price: Double, imageName: String) {
        // 1. Generate a unique ID from Firebase (but don't save yet)
        let newDocRef = Firestore.firestore().collection("menu_items").document()
        let newID = newDocRef.documentID
        
        // 2. Save to SQLite immediately (so UI updates instantly)
        _ = insertMenuItem(firebaseID: newID,
                           name: name,
                           description: description,
                           price: price,
                           imageName: imageName)
        
        // 3. Save to Firebase in the background
        let data: [String: Any] = [
            "name": name,
            "description": description,
            "price": price,
            "imageName": imageName
        ]
        
        newDocRef.setData(data) { error in
            if let error = error {
                print("Error saving to Firestore: \(error)")
            } else {
                print("Successfully saved to Firestore")
            }
        }
    }
    
    /// Delete an item from BOTH Firebase and SQLite
    func deleteMenuItem(localID: Int64, firebaseID: String) {
        // 1. Delete from SQLite (Instant UI removal)
        _ = deleteMenuItem(id: localID)
        
        // 2. Delete from Firebase
        if !firebaseID.isEmpty {
            Firestore.firestore().collection("menu_items").document(firebaseID).delete { error in
                if let error = error {
                    print("Error deleting from Firestore: \(error)")
                }
            }
        }
    }
    
    /// Update an item in BOTH Firebase and SQLite
    func updateMenuItemComposite(_ item: MenuItem) {
        // 1. Update SQLite
        _ = updateMenuItem(item)
        
        // 2. Update Firebase
        if !item.firebaseID.isEmpty {
            let data: [String: Any] = [
                "name": item.name,
                "description": item.description,
                "price": item.price,
                "imageName": item.imageName
            ]
            
            Firestore.firestore().collection("menu_items").document(item.firebaseID).updateData(data)
        }
    }
}

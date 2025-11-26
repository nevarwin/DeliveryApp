//
//  Database.swift
//  DeliveryApp
//
//  Lightweight SQLite helper and repository for flowers.
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
        seedInitialFlowersIfNeeded()
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
        let createFlowerTableSQL = """
        CREATE TABLE IF NOT EXISTS flowers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            imageName TEXT
        );
        """
        
        guard let db = db else { return }
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createFlowerTableSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Could not create flowers table.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Seeding
    
    private func seedInitialFlowersIfNeeded() {
        // If table already has data, skip
        if !fetchFlowers().isEmpty {
            return
        }
        
        let initialFlowers: [(String, String, Double, String)] = [
            ("Rose Bouquet", "Classic red roses wrapped beautifully.", 39.99, "rose"),
            ("Tulip Mix", "Colorful tulips perfect for spring.", 29.99, "tulip"),
            ("Sunflower Joy", "Bright sunflowers to light up any room.", 24.99, "sunflower"),
            ("Orchid Elegance", "Elegant white orchids in a pot.", 49.99, "orchid")
        ]
        
        for flower in initialFlowers {
            _ = insertFlower(name: flower.0,
                             description: flower.1,
                             price: flower.2,
                             imageName: flower.3)
        }
    }
    
    // MARK: - CRUD
    
    func fetchFlowers() -> [Flower] {
        guard let db = db else { return [] }
        
        let querySQL = "SELECT id, name, description, price, imageName FROM flowers ORDER BY name ASC;"
        var statement: OpaquePointer?
        var result: [Flower] = []
        
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
                
                let flower = Flower(id: id,
                                    name: name,
                                    description: description,
                                    price: price,
                                    imageName: imageName)
                result.append(flower)
            }
        } else {
            print("SELECT statement could not be prepared.")
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    @discardableResult
    func insertFlower(name: String, description: String, price: Double, imageName: String) -> Int64? {
        guard let db = db else { return nil }
        
        let insertSQL = "INSERT INTO flowers (name, description, price, imageName) VALUES (?, ?, ?, ?);"
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
}

// MARK: - Controller / Repository facade

final class FlowerController: ObservableObject {
    @Published private(set) var flowers: [Flower] = []
    
    private let db = DatabaseManager.shared
    
    init() {
        loadFlowers()
    }
    
    func loadFlowers() {
        flowers = db.fetchFlowers()
    }
}



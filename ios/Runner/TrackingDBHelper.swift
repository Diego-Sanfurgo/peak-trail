import Foundation
import SQLite3

class TrackingDBHelper {
    static let shared = TrackingDBHelper()
    var db: OpaquePointer?
    
    private init() {
        // Obtenemos la ruta de Documents (Misma que Flutter getApplicationDocumentsDirectory)
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dbPath = docDir.appendingPathComponent("tracking.db").path
            
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Swift: Base de datos abierta en \(dbPath)")
                enableWAL()
                createTableIfNotExists()
            } else {
                print("Swift: Error abriendo la DB")
            }
        }
    }
    
    private func enableWAL() {
        var error: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, "PRAGMA journal_mode=WAL;", nil, nil, &error) != SQLITE_OK {
            print("Swift: Error habilitando WAL")
        }
    }
    
    private func createTableIfNotExists() {
        // Drift espera esta estructura. Si Drift corre primero, ya estará creada.
        // Si Swift corre primero, la creamos nosotros.
        let createTableString = """
        CREATE TABLE IF NOT EXISTS tracking_points(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            altitude REAL,
            speed REAL,
            accuracy REAL,
            timestamp INTEGER NOT NULL
        );
        """
        
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                // Tabla creada o verificada
            } else {
                print("Swift: No se pudo crear la tabla.")
            }
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertPoint(lat: Double, lng: Double, alt: Double?, speed: Double?, acc: Double?, timestamp: Int64) {
        let insertStatementString = "INSERT INTO tracking_points (latitude, longitude, altitude, speed, accuracy, timestamp) VALUES (?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            // Bindear los valores (indices empiezan en 1)
            sqlite3_bind_double(insertStatement, 1, lat)
            sqlite3_bind_double(insertStatement, 2, lng)
            
            if let alt = alt { sqlite3_bind_double(insertStatement, 3, alt) } 
            else { sqlite3_bind_null(insertStatement, 3) }
            
            if let spd = speed { sqlite3_bind_double(insertStatement, 4, spd) }
            else { sqlite3_bind_null(insertStatement, 4) }
            
            if let acc = acc { sqlite3_bind_double(insertStatement, 5, acc) }
            else { sqlite3_bind_null(insertStatement, 5) }
            
            sqlite3_bind_int64(insertStatement, 6, timestamp)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Swift: Punto insertado correctamente.")
            } else {
                print("Swift: Error al insertar punto.")
            }
        }
        sqlite3_finalize(insertStatement)
    }
    
    deinit {
        sqlite3_close(db)
    }
}
//
//  DBManager.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 08/04/25.
//


import Foundation
import SQLite3

class DBManager {
    static let shared = DBManager()
    var db: OpaquePointer?

    init() {
        openDatabase()
        createTables()
        addColumnIfNeeded(columnName: "isDeleted", toTable: "Students", columnDefinition: "isDeleted INTEGER DEFAULT 0")
    }

    func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("CampusBuddy.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Unable to open database.")
        } else {
            print("✅ Database opened at \(fileURL.path)")
        }
    }

    func createTables() {
        let createStudents = """
        CREATE TABLE IF NOT EXISTS Students (
            username TEXT PRIMARY KEY,
            password TEXT,
            name TEXT,
            email TEXT,
            mobile TEXT,
            address TEXT,
            college TEXT,
            studentID TEXT,
            isDeleted INTEGER DEFAULT 0
        );
        """

        let createNotes = """
        CREATE TABLE IF NOT EXISTS Notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            title TEXT,
            content TEXT
        );
        """

        let createTasks = """
        CREATE TABLE IF NOT EXISTS Tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            task TEXT,
            done INTEGER
        );
        """

        let createSchedule = """
        CREATE TABLE IF NOT EXISTS Schedule (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            subject TEXT,
            time TEXT
        );
        """

        let createTrash = """
        CREATE TABLE IF NOT EXISTS Trash (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            data TEXT,
            deletedAt TEXT
        );
        """

        execute(query: createStudents)
        execute(query: createNotes)
        execute(query: createTasks)
        execute(query: createSchedule)
        execute(query: createTrash)
    }

    func execute(query: String) {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Query executed: \(query.prefix(40))...")
            } else {
                print("❌ Execution failed: \(query)")
            }
        } else {
            print("❌ Preparation failed: \(query)")
        }
        sqlite3_finalize(stmt)
    }

    func moveToTrash(type: String, data: String) {
        let date = ISO8601DateFormatter().string(from: Date())
        let query = "INSERT INTO Trash (type, data, deletedAt) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (type as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (data as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (date as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    func softDeleteStudent(username: String) {
        let query = "UPDATE Students SET isDeleted = 1 WHERE username = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ Soft deleted student: \(username)")
            }
        }

        sqlite3_finalize(stmt)
    }

    func addColumnIfNeeded(columnName: String, toTable table: String, columnDefinition: String) {
        let pragma = "PRAGMA table_info(\(table));"
        var stmt: OpaquePointer?
        var columnExists = false

        if sqlite3_prepare_v2(db, pragma, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(stmt, 1))
                if name == columnName {
                    columnExists = true
                    break
                }
            }
        }

        sqlite3_finalize(stmt)

        if !columnExists {
            let alter = "ALTER TABLE \(table) ADD COLUMN \(columnDefinition);"
            sqlite3_exec(db, alter, nil, nil, nil)
            print("✅ Column '\(columnName)' added to '\(table)' table.")
        } else {
            print("ℹ️ Column '\(columnName)' already exists in '\(table)'.")
        }
    }
}

extension DBManager {
    func updatePassword(username: String, oldPassword: String, newPassword: String) -> Bool {
        let query = "SELECT * FROM Students WHERE username = ? AND password = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (oldPassword as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_ROW {
                sqlite3_finalize(stmt)

                let updateQuery = "UPDATE Students SET password = ? WHERE username = ?;"
                var updateStmt: OpaquePointer?

                if sqlite3_prepare_v2(db, updateQuery, -1, &updateStmt, nil) == SQLITE_OK {
                    sqlite3_bind_text(updateStmt, 1, (newPassword as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(updateStmt, 2, (username as NSString).utf8String, -1, nil)

                    if sqlite3_step(updateStmt) == SQLITE_DONE {
                        sqlite3_finalize(updateStmt)
                        return true
                    }
                    sqlite3_finalize(updateStmt)
                }
            }
        }
        sqlite3_finalize(stmt)
        return false
    }
}

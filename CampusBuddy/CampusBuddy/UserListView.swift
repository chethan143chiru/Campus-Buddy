//
//  UserListView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//

import SwiftUI
import SQLite3

struct User: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let name: String
    let email: String
}

struct UserListView: View {
    @State private var users: [User] = []

    var body: some View {
        VStack {
            if users.isEmpty {
                Text("No registered students.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(users) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)
                            Text("📧 \(user.email)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("👤 Username: \(user.username)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteUser)
                }
            }
        }
        .navigationTitle("Registered Students")
        .onAppear {
            loadUsers()
        }
    }

    func loadUsers() {
        users.removeAll()

        let query = "SELECT username, name, email FROM Students;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let username = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let email = String(cString: sqlite3_column_text(stmt, 2))
                let user = User(username: username, name: name, email: email)
                users.append(user)
            }
            sqlite3_finalize(stmt)
        } else {
            print("❌ Failed to load users.")
        }
    }

    func deleteUser(at offsets: IndexSet) {
        for index in offsets {
            let user = users[index]
            let query = "DELETE FROM Students WHERE username = ?;"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, (user.username as NSString).utf8String, -1, nil)

                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("✅ Deleted: \(user.username)")
                } else {
                    print("❌ Failed to delete: \(user.username)")
                }
                sqlite3_finalize(stmt)
            }
        }

        // Refresh list
        loadUsers()
    }
}

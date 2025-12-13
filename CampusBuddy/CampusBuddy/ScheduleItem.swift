//
//  ScheduleItem.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 08/04/25.
//


import SwiftUI
import SQLite3

struct ScheduleItem: Identifiable {
    let id: Int
    let subject: String
    let time: String
}

struct ScheduleView: View {
    @State private var schedule: [ScheduleItem] = []
    @State private var subject = ""
    @State private var time = ""

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Add Class Schedule")) {
                        TextField("Subject", text: $subject)
                        TextField("Time", text: $time)

                        Button("Add Schedule") {
                            addSchedule()
                        }
                        .disabled(subject.isEmpty || time.isEmpty)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                List {
                    ForEach(schedule) { item in
                        VStack(alignment: .leading) {
                            Text(item.subject)
                                .font(.headline)
                            Text("🕒 \(item.time)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteSchedule)
                }
            }
            .navigationTitle("Class Schedule")
            .onAppear {
                DBManager.shared.createTables()
                loadSchedule()
            }
        }
    }

    // MARK: - Add schedule (per user)
    func addSchedule() {
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = "INSERT INTO Schedule (username, subject, time) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (subject as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (time as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                subject = ""
                time = ""
                loadSchedule()
            }
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - Load schedule (for current user)
    func loadSchedule() {
        schedule.removeAll()
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = "SELECT id, subject, time FROM Schedule WHERE username = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let subject = String(cString: sqlite3_column_text(stmt, 1))
                let time = String(cString: sqlite3_column_text(stmt, 2))

                schedule.append(ScheduleItem(id: Int(id), subject: subject, time: time))
            }
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - Delete schedule
    func deleteSchedule(at offsets: IndexSet) {
        for index in offsets {
            let item = schedule[index]

            // Optional: Move to Trash
            let trashData = "subject=\(item.subject);time=\(item.time)"
            DBManager.shared.moveToTrash(type: "Schedule", data: trashData)

            let query = "DELETE FROM Schedule WHERE id = ?;"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(item.id))
                if sqlite3_step(stmt) == SQLITE_DONE {
                    loadSchedule()
                }
            }

            sqlite3_finalize(stmt)
        }
    }
}

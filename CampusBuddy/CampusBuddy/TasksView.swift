//
//  TasksView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 11/04/25.
//


import SwiftUI
import SQLite3

struct Task: Identifiable {
    let id: Int
    let task: String
    let done: Bool
}

struct TasksView: View {
    @State private var tasks: [Task] = []
    @State private var newTask = ""

    var body: some View {
        VStack {
            HStack {
                TextField("New Task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Add") {
                    addTask()
                }
                .disabled(newTask.isEmpty)
            }
            .padding()

            List {
                ForEach(tasks) { task in
                    HStack {
                        Text(task.task)
                        Spacer()
                        if task.done {
                            Text("✅")
                                .foregroundColor(.green)
                        }
                    }
                }
                .onDelete(perform: deleteTask)
            }
        }
        .navigationTitle("Task Manager")
        .onAppear {
            DBManager.shared.createTables()
            loadTasks()
        }
    }

    // MARK: - Add Task (User-specific)
    func addTask() {
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = "INSERT INTO Tasks (username, task, done) VALUES (?, ?, 0);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (newTask as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                newTask = ""
                loadTasks()
            }
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - Load Tasks (User-specific)
    func loadTasks() {
        tasks.removeAll()
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = "SELECT id, task, done FROM Tasks WHERE username = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let taskText = String(cString: sqlite3_column_text(stmt, 1))
                let done = sqlite3_column_int(stmt, 2) == 1

                tasks.append(Task(id: id, task: taskText, done: done))
            }
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - Delete Task and move to Trash
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]

            // Move to trash
            let trashData = "task=\(task.task);done=\(task.done ? "1" : "0")"
            DBManager.shared.moveToTrash(type: "Task", data: trashData)

            // Delete from database
            let query = "DELETE FROM Tasks WHERE id = ?;"
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(task.id))
                if sqlite3_step(stmt) == SQLITE_DONE {
                    loadTasks()
                }
            }

            sqlite3_finalize(stmt)
        }
    }
}

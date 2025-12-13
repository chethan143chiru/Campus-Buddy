//
//  NotesView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 08/04/25.
//


import SwiftUI
import SQLite3

// ✅ Note model scoped per user
struct Note: Identifiable {
    let id: Int
    let title: String
    let content: String
}

struct NotesView: View {
    @State private var notes: [Note] = []
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Form {
                    Section(header: Text("Add New Note")) {
                        TextField("Title", text: $title)
                        TextField("Content", text: $content)

                        Button("Save Note") {
                            saveNote()
                        }
                        .disabled(title.isEmpty || content.isEmpty)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }

                List {
                    ForEach(notes) { note in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteNote)
                }
            }
            .navigationTitle("Notes Manager")
            .onAppear {
                DBManager.shared.createTables()
                loadNotes()
            }
        }
    }

    // MARK: - Save note scoped by user
    func saveNote() {
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = "INSERT INTO Notes (username, title, content) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (content as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                title = ""
                content = ""
                loadNotes()
            }
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - Load only notes for the logged-in user
    func loadNotes() {
        notes.removeAll()
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = "SELECT id, title, content FROM Notes WHERE username = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let content = String(cString: sqlite3_column_text(stmt, 2))
                notes.append(Note(id: Int(id), title: title, content: content))
            }
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - Delete note & move to Trash
    func deleteNote(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            let data = "id=\(note.id);title=\(note.title);content=\(note.content)"
            DBManager.shared.moveToTrash(type: "Note", data: data)

            let query = "DELETE FROM Notes WHERE id = ?;"
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_int(stmt, 1, Int32(note.id))
                sqlite3_step(stmt)
            }
            sqlite3_finalize(stmt)
        }
        loadNotes()
    }
}

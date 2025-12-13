//
//  ProfileView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//


import SwiftUI
import SQLite3

struct Student: Identifiable, Equatable {
    let id = UUID()
    let username: String
    var name: String
    var email: String
    var mobile: String
    var address: String
    var college: String
    var studentID: String
    var isEditing: Bool = false
}

struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var students: [Student] = []
    @State private var showDeleteAlert = false
    @State private var studentToDelete: Student?

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("👤 My Profile")
                    .font(.largeTitle)
                    .bold()

                ForEach(Array(students.enumerated()), id: \.element.id) { index, item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🧑‍🎓 Username: \(item.username)").font(.headline)

                        if item.isEditing {
                            TextField("Name", text: binding(for: item).name)
                            TextField("Email", text: binding(for: item).email)
                            TextField("Mobile", text: binding(for: item).mobile)
                            TextField("Address", text: binding(for: item).address)
                            TextField("College", text: binding(for: item).college)
                            TextField("Student ID", text: binding(for: item).studentID)

                            HStack {
                                Button("💾 Save") {
                                    updateStudent(binding(for: item).wrappedValue)
                                    toggleEdit(for: item)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .background(Color.green)
                                .cornerRadius(8)

                                Button("❌ Cancel") {
                                    loadStudents()
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .background(Color.gray)
                                .cornerRadius(8)
                            }
                        } else {
                            Text("📛 Name: \(item.name)")
                            Text("📧 Email: \(item.email)")
                            Text("📱 Mobile: \(item.mobile)")
                            Text("🏠 Address: \(item.address)")
                            Text("🏫 College: \(item.college)")
                            Text("🆔 Student ID: \(item.studentID)")

                            HStack(spacing: 12) {
                                Button("✏️ Edit") {
                                    toggleEdit(for: item)
                                }
                                .foregroundColor(.blue)

                                Button("🗑 Delete") {
                                    studentToDelete = item
                                    showDeleteAlert = true
                                }
                                .foregroundColor(.red)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }

                Button("Logout") {
                    logout()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("My Profile")
        .onAppear {
            loadStudents()
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this profile? It will be moved to Trash."),
                primaryButton: .destructive(Text("Delete")) {
                    if let student = studentToDelete {
                        softDeleteStudent(student)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    func binding(for student: Student) -> Binding<Student> {
        guard let index = students.firstIndex(where: { $0.username == student.username }) else {
            fatalError("Student not found")
        }
        return $students[index]
    }

    func toggleEdit(for student: Student) {
        if let index = students.firstIndex(where: { $0.username == student.username }) {
            students[index].isEditing.toggle()
        }
    }

    // MARK: - Load only current user's profile
    func loadStudents() {
        students.removeAll()
        guard let username = UserDefaults.standard.string(forKey: "lastUsername") else { return }

        let query = """
        SELECT username, name, email, mobile, address, college, studentID
        FROM Students
        WHERE username = ? AND isDeleted = 0;
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)

            while sqlite3_step(stmt) == SQLITE_ROW {
                let username = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let email = String(cString: sqlite3_column_text(stmt, 2))
                let mobile = String(cString: sqlite3_column_text(stmt, 3))
                let address = String(cString: sqlite3_column_text(stmt, 4))
                let college = String(cString: sqlite3_column_text(stmt, 5))
                let studentID = String(cString: sqlite3_column_text(stmt, 6))

                let student = Student(
                    username: username,
                    name: name,
                    email: email,
                    mobile: mobile,
                    address: address,
                    college: college,
                    studentID: studentID
                )
                students.append(student)
            }
        }

        sqlite3_finalize(stmt)
    }

    func updateStudent(_ student: Student) {
        let query = """
        UPDATE Students SET
            name = ?, email = ?, mobile = ?, address = ?, college = ?, studentID = ?
        WHERE username = ?;
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (student.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (student.email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (student.mobile as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (student.address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (student.college as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (student.studentID as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (student.username as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                loadStudents()
            }
        }

        sqlite3_finalize(stmt)
    }

    func softDeleteStudent(_ student: Student) {
        let query = "UPDATE Students SET isDeleted = 1 WHERE username = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (student.username as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                // Move profile to trash
                let studentData: [String: Any] = [
                    "username": student.username,
                    "name": student.name,
                    "email": student.email,
                    "mobile": student.mobile,
                    "address": student.address,
                    "college": student.college,
                    "studentID": student.studentID
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: studentData, options: []),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    DBManager.shared.moveToTrash(type: "Student", data: jsonString)
                }
                loadStudents()
            }
        }

        sqlite3_finalize(stmt)
    }

    func logout() {
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "lastUsername")
    }
}

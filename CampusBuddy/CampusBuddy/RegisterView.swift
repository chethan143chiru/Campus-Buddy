//
//  RegisterView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//


import SwiftUI
import SQLite3

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var name = ""
    @State private var email = ""
    @State private var mobile = ""
    @State private var address = ""
    @State private var college = ""
    @State private var studentID = ""

    @State private var message = ""
    @State private var isError = false

    var body: some View {
        Form {
            Section(header: Text("Register Student")) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Mobile", text: $mobile)
                TextField("Address", text: $address)
                TextField("College", text: $college)
                TextField("Student ID", text: $studentID)
            }

            Button("Register") {
                registerStudent()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(isError ? .red : .green)
                    .padding(.top)
            }
        }
        .navigationTitle("Register")
    }

    func registerStudent() {
        // ✅ Check all fields
        if username.isEmpty || password.isEmpty || name.isEmpty || email.isEmpty || mobile.isEmpty || address.isEmpty || college.isEmpty || studentID.isEmpty {
            message = "❗ Please fill in all fields to register."
            isError = true
            return
        }

        let insertQuery = """
        INSERT INTO Students (username, password, name, email, mobile, address, college, studentID)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (password as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (mobile as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (college as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 8, (studentID as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                message = "✅ Student registered successfully!"
                isError = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            } else {
                message = "❌ Username already exists!"
                isError = true
            }
        } else {
            message = "❌ Registration failed."
            isError = true
        }

        sqlite3_finalize(stmt)
    }
}

//
//  EditProfileView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//


import SwiftUI
import SQLite3

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var username = UserDefaults.standard.string(forKey: "lastUsername") ?? ""

    @State private var name = UserDefaults.standard.string(forKey: "student_name") ?? ""
    @State private var email = UserDefaults.standard.string(forKey: "student_email") ?? ""
    @State private var mobile = UserDefaults.standard.string(forKey: "student_mobile") ?? ""
    @State private var address = UserDefaults.standard.string(forKey: "student_address") ?? ""
    @State private var college = UserDefaults.standard.string(forKey: "student_college") ?? ""
    @State private var studentID = UserDefaults.standard.string(forKey: "student_studentID") ?? ""

    var body: some View {
        Form {
            Section(header: Text("Edit Profile")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Mobile", text: $mobile)
                TextField("Address", text: $address)
                TextField("College", text: $college)
                TextField("Student ID", text: $studentID)
            }

            Button("Save Changes") {
                updateProfileInDB()
                dismiss()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
        }
        .navigationTitle("Edit Profile")
    }

    func updateProfileInDB() {
        let updateQuery = """
        UPDATE Students
        SET name = ?, email = ?, mobile = ?, address = ?, college = ?, studentID = ?
        WHERE username = ?;
        """

        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, updateQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (email as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (mobile as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (address as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (college as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (studentID as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (username as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_DONE {
                // Also update UserDefaults
                UserDefaults.standard.set(name, forKey: "student_name")
                UserDefaults.standard.set(email, forKey: "student_email")
                UserDefaults.standard.set(mobile, forKey: "student_mobile")
                UserDefaults.standard.set(address, forKey: "student_address")
                UserDefaults.standard.set(college, forKey: "student_college")
                UserDefaults.standard.set(studentID, forKey: "student_studentID")
            }
        }

        sqlite3_finalize(stmt)
    }
}

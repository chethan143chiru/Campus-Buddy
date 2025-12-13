//
//  LoginView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 08/04/25.
//


import SwiftUI
import SQLite3

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var studentCount = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // ✅ Logo
                Image("cGeniusLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .padding(.top)

                Text("🎓 Campus Buddy Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Login") {
                    loginUser()
                }
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)

                NavigationLink(destination: RegisterView()) {
                    Text("📋 Register New Account")
                        .foregroundColor(.green)
                }

                NavigationLink(destination: ForgotPasswordView(username: username)) {
                    Text("🔑 Forgot Password?")
                        .foregroundColor(.orange)
                }

                // ✅ Show student count
                Text("👥 Total Registered Students: \(studentCount)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                HomeView()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadStudentCount()
            }
        }
    }

    // MARK: - Login logic
    func loginUser() {
        let db = DBManager.shared.db
        let loginQuery = "SELECT * FROM Students WHERE username = ? AND password = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, loginQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (password as NSString).utf8String, -1, nil)

            if sqlite3_step(stmt) == SQLITE_ROW {
                let isDeleted = sqlite3_column_int(stmt, 8)

                if isDeleted == 1 {
                    restoreDeletedUser(username: username)
                }

                // Store session
                UserDefaults.standard.set(username, forKey: "lastUsername")
                UserDefaults.standard.set(true, forKey: "isLoggedIn")

                // Store user info
                UserDefaults.standard.set(String(cString: sqlite3_column_text(stmt, 2)), forKey: "student_name")
                UserDefaults.standard.set(String(cString: sqlite3_column_text(stmt, 3)), forKey: "student_email")
                UserDefaults.standard.set(String(cString: sqlite3_column_text(stmt, 4)), forKey: "student_mobile")
                UserDefaults.standard.set(String(cString: sqlite3_column_text(stmt, 5)), forKey: "student_address")
                UserDefaults.standard.set(String(cString: sqlite3_column_text(stmt, 6)), forKey: "student_college")
                UserDefaults.standard.set(String(cString: sqlite3_column_text(stmt, 7)), forKey: "student_studentID")

                isLoggedIn = true
            } else {
                alertMessage = "Invalid username or password."
                showAlert = true
            }
        } else {
            alertMessage = "Database error during login."
            showAlert = true
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - Restore soft-deleted user
    func restoreDeletedUser(username: String) {
        let restoreQuery = "UPDATE Students SET isDeleted = 0 WHERE username = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, restoreQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (username as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }

        sqlite3_finalize(stmt)
    }

    // MARK: - Count total registered students
    func loadStudentCount() {
        let query = "SELECT COUNT(*) FROM Students WHERE isDeleted = 0;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(DBManager.shared.db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                studentCount = Int(sqlite3_column_int(stmt, 0))
            }
        }

        sqlite3_finalize(stmt)
    }
}

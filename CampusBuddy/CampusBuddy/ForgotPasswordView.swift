//
//  ForgotPasswordView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 10/04/25.
//


import SwiftUI
import SQLite3

struct ForgotPasswordView: View {
    var username: String
    @Environment(\.presentationMode) var presentationMode
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reset Password for \(username)")) {
                    SecureField("Old Password", text: $oldPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }

                Button("Update Password") {
                    if newPassword != confirmPassword {
                        alertMessage = "New passwords do not match!"
                        showAlert = true
                        return
                    }

                    if DBManager.shared.updatePassword(username: username, oldPassword: oldPassword, newPassword: newPassword) {
                        alertMessage = "Password updated successfully!"
                        showAlert = true
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        alertMessage = "Old password is incorrect or update failed."
                        showAlert = true
                    }
                }
            }
            .navigationTitle("Forgot Password")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

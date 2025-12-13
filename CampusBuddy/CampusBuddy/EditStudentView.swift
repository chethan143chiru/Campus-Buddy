//
//  EditStudentView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//


import SwiftUI

struct EditStudentView: View {
    @Environment(\.dismiss) var dismiss
    @State var student: Student
    var onSave: (Student) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $student.name)
                TextField("Email", text: $student.email)
                TextField("Mobile", text: $student.mobile)
                TextField("Address", text: $student.address)
                TextField("College", text: $student.college)
                TextField("Student ID", text: $student.studentID)
            }

            Button("Save Changes") {
                onSave(student)
                dismiss()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
        }
    }
}

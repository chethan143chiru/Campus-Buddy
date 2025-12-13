//
//  HomeView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 08/04/25.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // ✅ Logo at the top center
                    Image("cGeniusLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.top)

                    Text("🎓 Campus Buddy Dashboard")
                        .font(.largeTitle)
                        .bold()

                    // ✅ My Profile at top-left
                    HStack {
                        NavigationLink(destination: ProfileView()) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text("My Profile")
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // ✅ Centered grid of remaining cards
                    VStack(spacing: 16) {
                        NavigationLink(destination: NotesView()) {
                            HStack {
                                Image(systemName: "note.text")
                                Text("Notes Manager")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(10)
                        }

                        NavigationLink(destination: TasksView()) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Task Manager")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(10)
                        }

                        NavigationLink(destination: ScheduleView()) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Class Schedule")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                        }

                        NavigationLink(destination: ExportView()) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Students")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Campus Buddy")
        }
    }
}

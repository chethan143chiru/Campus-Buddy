//
//  SplashView.swift
//  CampusBuddy
//
//  Created by CHETHAN R on 09/04/25.
//


import SwiftUI

struct SplashView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                if isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            } else {
                splashContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Delay for splash screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }

    var splashContent: some View {
        VStack {
            Spacer()
            Image("cGeniusLogo") // 👈 Make sure this matches your asset name
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(32)
                .shadow(radius: 10)

            Text("Campus Buddy")
                .font(.largeTitle)
                .bold()
                .padding(.top, 16)
            Spacer()

            Text("Empowering Student Success")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

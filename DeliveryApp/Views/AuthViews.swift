//
//  AuthViews.swift
//  DeliveryApp
//
//  Simple onboarding and login screens.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppStateController
    
    var body: some View {
        Group {
            if !appState.isOnboarded {
                OnboardingView()
            } else if !appState.isLoggedIn {
                LoginView()
            } else {
                ContentView()
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppStateController
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .foregroundStyle(.orange)
            
            Text("Welcome to Local Eats")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Discover nearby favorites, add them to your cart, and get them delivered fast.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                appState.isOnboarded = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var appState: AppStateController
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Log In")
                .font(.largeTitle.bold())
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            Button {
                // Simple demo login – in a real app you'd validate credentials.
                appState.isLoggedIn = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}



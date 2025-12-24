//
//  AuthViews.swift
//  DeliveryApp
//
//  Simple onboarding and login screens.
//

import SwiftUI
import AuthenticationServices

struct RootView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if !appViewModel.isOnboarded {
                OnboardingView()
            } else if !appViewModel.isLoggedIn {
                LoginView()
            } else {
                ContentView()
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
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
                appViewModel.completeOnboarding()
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
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Log In")
                .font(.largeTitle.bold())
            
            VStack(spacing: 16) {
                if let error = appViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                     appViewModel.authenticate(email: email, password: password)
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Rectangle().frame(height: 1).foregroundStyle(.gray.opacity(0.3))
                Text("OR").font(.caption2).foregroundStyle(.secondary).fontWeight(.bold)
                Rectangle().frame(height: 1).foregroundStyle(.gray.opacity(0.3))
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                // Google Sign In (Custom)
                Button {
                    appViewModel.signInWithGoogle()
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                
                SignInWithAppleButton(.signIn) { request in
                    // ViewModel to prepare the nonce
                    appViewModel.prepareAppleRequest(request)
                } onCompletion: { result in
                    // Pass the result back to the ViewModel
                    appViewModel.handleAppleSignInResult(result)
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
